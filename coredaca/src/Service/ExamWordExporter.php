<?php
declare(strict_types=1);

namespace App\Service;

use RuntimeException;
use ZipArchive;

/** Writes a real OOXML .docx without adding a runtime package to the legacy PHP app. */
class ExamWordExporter
{
    private $paragraphs = [];
    private $media = [];
    private $relationships = [];
    private $nextImageId = 2;

    public function create(array $data, callable $loadImage): string
    {
        $exam = $data['exam'];
        $this->paragraph('MEDUC · BỘ ĐỀ Y KHOA', 'Kicker');
        $this->paragraph($this->plain($exam['name'] ?? 'Bộ đề'), 'Title');
        $this->paragraph(implode('  |  ', array_filter([
            $this->plain($exam['school'] ?? ''),
            $this->plain($exam['module'] ?? ''),
            count($data['questions'] ?? []) . ' câu hỏi'
        ])), 'Subtitle');
        $this->paragraph('Mã đề: ' . (int)($exam['id'] ?? 0), 'Meta');

        foreach ($data['questions'] ?? [] as $index => $question) {
            $this->paragraph('Câu ' . ($index + 1), 'Heading1');
            $this->content($question['content'] ?? '');
            foreach ($question['images'] ?? [] as $media) {
                $hash = (string)($media['url_hash'] ?? '');
                if ($hash) {
                    $this->addImage($loadImage($hash));
                }
            }
            foreach ($question['options'] ?? [] as $option) {
                $label = trim((string)($option['key'] ?? ''));
                $this->paragraph($label . '. ' . $this->plain($option['content'] ?? ''), 'Option');
            }
            if (!empty($question['rubric']['criteria'])) {
                $this->paragraph('Yêu cầu: ' . $this->plain($question['rubric']['criteria']), 'Option');
            }
        }

        $this->paragraphs[] = '<w:p><w:r><w:br w:type="page"/></w:r></w:p>';
        $this->paragraph('ĐÁP ÁN VÀ GIẢI THÍCH', 'Title');
        foreach ($data['questions'] ?? [] as $index => $question) {
            $correct = [];
            foreach ($question['options'] ?? [] as $option) {
                if (!empty($option['is_correct'])) {
                    $correct[] = (string)($option['key'] ?? '');
                }
            }
            $this->paragraph('Câu ' . ($index + 1) . ': ' . ($correct ? implode(', ', $correct) : 'Tự luận / chưa có đáp án'), 'Heading2');
            if (!empty($question['explanation'])) {
                $this->content($question['explanation']);
            }
            if (!empty($question['rubric']['sample_answer'])) {
                $this->paragraph('Gợi ý trả lời:', 'Meta');
                $this->content($question['rubric']['sample_answer']);
            }
        }

        $path = tempnam(sys_get_temp_dir(), 'meduc-docx-');
        if (!$path) {
            throw new RuntimeException('Không tạo được tệp Word.');
        }
        $zip = new ZipArchive();
        if ($zip->open($path, ZipArchive::OVERWRITE) !== true) {
            @unlink($path);
            throw new RuntimeException('Không đóng gói được tệp Word.');
        }
        $types = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
            . '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
            . '<Default Extension="xml" ContentType="application/xml"/>'
            . '<Default Extension="png" ContentType="image/png"/>'
            . '<Default Extension="jpg" ContentType="image/jpeg"/>'
            . '<Default Extension="gif" ContentType="image/gif"/>'
            . '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
            . '<Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>'
            . '</Types>';
        $zip->addFromString('[Content_Types].xml', $types);
        $zip->addFromString('_rels/.rels', '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            . '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>'
            . '</Relationships>');
        $zip->addFromString('word/document.xml', '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"'
            . ' xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"'
            . ' xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"'
            . ' xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"'
            . ' xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"><w:body>'
            . implode('', $this->paragraphs)
            . '<w:sectPr><w:pgSz w:w="11906" w:h="16838"/>'
            . '<w:pgMar w:top="1134" w:right="1134" w:bottom="1134" w:left="1134"/></w:sectPr>'
            . '</w:body></w:document>');
        $zip->addFromString('word/styles.xml', $this->styles());
        $zip->addFromString('word/_rels/document.xml.rels', '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            . '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
            . implode('', $this->relationships) . '</Relationships>');
        foreach ($this->media as $name => $bytes) {
            $zip->addFromString('word/media/' . $name, $bytes);
        }
        $zip->close();
        return $path;
    }

    private function content($html): void
    {
        $text = $this->plain($html);
        foreach (preg_split('/\n+/u', $text) as $line) {
            $line = trim($line);
            if ($line !== '') {
                $this->paragraph($line, 'Normal');
            }
        }
    }

    private function plain($html): string
    {
        $html = (string)$html;
        $html = preg_replace('~<(script|style)[^>]*>.*?</\1>~is', '', $html);
        $html = preg_replace('~</?(?:p|div|br|li|tr|h[1-6])[^>]*>~i', "\n", $html);
        $html = preg_replace('~</?(?:td|th)[^>]*>~i', '  |  ', $html);
        $text = html_entity_decode(strip_tags($html), ENT_QUOTES | ENT_HTML5, 'UTF-8');
        $text = preg_replace('/[\x00-\x08\x0B\x0C\x0E-\x1F]/', '', $text);
        return trim(preg_replace('/[ \t]+/u', ' ', $text));
    }

    private function paragraph(string $text, string $style): void
    {
        $escaped = htmlspecialchars($text, ENT_XML1 | ENT_QUOTES, 'UTF-8');
        $this->paragraphs[] = '<w:p><w:pPr><w:pStyle w:val="' . $style . '"/></w:pPr>'
            . '<w:r><w:t xml:space="preserve">' . $escaped . '</w:t></w:r></w:p>';
    }

    private function addImage(?array $image): void
    {
        if (!$image) {
            return;
        }
        $mime = $image['mime'];
        $bytes = $image['bytes'];
        if ($mime === 'image/png') {
            $ext = 'png';
        } elseif ($mime === 'image/jpeg') {
            $ext = 'jpg';
        } elseif ($mime === 'image/gif') {
            $ext = 'gif';
        } elseif (function_exists('imagecreatefromstring')) {
            $resource = @imagecreatefromstring($bytes);
            if (!$resource) {
                return;
            }
            ob_start();
            imagepng($resource);
            $bytes = ob_get_clean();
            imagedestroy($resource);
            $ext = 'png';
        } else {
            return;
        }
        $id = $this->nextImageId++;
        $name = 'image' . $id . '.' . $ext;
        $this->media[$name] = $bytes;
        $this->relationships[] = '<Relationship Id="rId' . $id . '" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/' . $name . '"/>';
        $scale = min(1, 5486400 / (max(1, $image['width']) * 9525));
        $cx = (int)(max(1, $image['width']) * 9525 * $scale);
        $cy = (int)(max(1, $image['height']) * 9525 * $scale);
        $this->paragraphs[] = '<w:p><w:r><w:drawing><wp:inline distT="0" distB="0" distL="0" distR="0">'
            . '<wp:extent cx="' . $cx . '" cy="' . $cy . '"/><wp:docPr id="' . $id . '" name="Hình minh họa ' . $id . '"/>'
            . '<a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture"><pic:pic>'
            . '<pic:nvPicPr><pic:cNvPr id="' . $id . '" name="' . $name . '"/><pic:cNvPicPr/></pic:nvPicPr>'
            . '<pic:blipFill><a:blip r:embed="rId' . $id . '"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill>'
            . '<pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="' . $cx . '" cy="' . $cy . '"/></a:xfrm>'
            . '<a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr></pic:pic></a:graphicData></a:graphic>'
            . '</wp:inline></w:drawing></w:r></w:p>';
    }

    private function styles(): string
    {
        return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
            . '<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/>'
            . '<w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial"/><w:sz w:val="22"/></w:rPr></w:style>'
            . '<w:style w:type="paragraph" w:styleId="Kicker"><w:name w:val="Kicker"/><w:rPr><w:b/><w:color w:val="C81D32"/><w:sz w:val="19"/></w:rPr></w:style>'
            . '<w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:rPr><w:b/><w:sz w:val="34"/></w:rPr></w:style>'
            . '<w:style w:type="paragraph" w:styleId="Subtitle"><w:name w:val="Subtitle"/><w:rPr><w:color w:val="59606D"/><w:sz w:val="21"/></w:rPr></w:style>'
            . '<w:style w:type="paragraph" w:styleId="Meta"><w:name w:val="Meta"/><w:rPr><w:color w:val="777777"/><w:sz w:val="18"/></w:rPr></w:style>'
            . '<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="Heading 1"/><w:pPr><w:spacing w:before="260"/></w:pPr><w:rPr><w:b/><w:color w:val="C81D32"/><w:sz w:val="25"/></w:rPr></w:style>'
            . '<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="Heading 2"/><w:pPr><w:spacing w:before="180"/></w:pPr><w:rPr><w:b/><w:sz w:val="22"/></w:rPr></w:style>'
            . '<w:style w:type="paragraph" w:styleId="Option"><w:name w:val="Option"/><w:pPr><w:ind w:left="360"/></w:pPr></w:style>'
            . '</w:styles>';
    }
}
