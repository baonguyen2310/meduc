<?php
declare(strict_types=1);

namespace App\View\Helper;

use Cake\View\Helper;

class BlogDetailHelper extends Helper
{
    public $helpers = ['Blog'];

    /** Presentation only: original article, media, FAQ and configured courses stay in the CMS. */
    public function prepare(array $article, string $lang): array
    {
        if (empty($article['id']) || empty($article['status']) || !empty($article['draft'])) return [];
        $catalogue = $this->Blog->catalogue(0, $lang);
        $current = [];
        foreach ($catalogue['items'] as $item) {
            if ($item['id'] === (int) $article['id']) { $current = $item; break; }
        }
        if (!$current) return [];
        $topicId = $current['topics'][0] ?? 0;
        $topic = $catalogue['topics'][$topicId] ?? ['id' => 0, 'name' => 'Góc học tập', 'url' => 'blog'];
        $content = $this->clean((string) ($article['content'] ?? ''), true);
        $description = $this->plain((string) ($article['description'] ?? ''));
        $words = preg_split('/\s+/u', $this->plain($content['html']), -1, PREG_SPLIT_NO_EMPTY) ?: [];
        $related = array_values(array_filter($catalogue['items'], function ($item) use ($current) {
            return $item['id'] !== $current['id'];
        }));
        usort($related, function ($a, $b) use ($current) {
            $scoreA = count(array_intersect($a['topics'], $current['topics'])) > 0 ? 1 : 0;
            $scoreB = count(array_intersect($b['topics'], $current['topics'])) > 0 ? 1 : 0;
            return $scoreB <=> $scoreA ?: $b['created'] <=> $a['created'] ?: $b['id'] <=> $a['id'];
        });
        $series = array_values(array_filter($catalogue['items'], function ($item) use ($topicId) {
            return $topicId && in_array($topicId, $item['topics'], true);
        }));
        $previous = $next = [];
        foreach ($series as $index => $item) {
            if ($item['id'] !== $current['id']) continue;
            $previous = $series[$index - 1] ?? [];
            $next = $series[$index + 1] ?? [];
            break;
        }
        $faqs = [];
        $rawFaqs = json_decode((string) ($article['attributes']['cauhoithuonggap']['value'] ?? ''), true);
        foreach (is_array($rawFaqs) ? $rawFaqs : [] as $faq) {
            $name = $this->plain((string) ($faq['name_' . $lang] ?? ''));
            $answer = $this->clean((string) ($faq['description_' . $lang] ?? ''));
            if ($name && $answer['html']) $faqs[] = ['name' => $name, 'html' => $answer['html']];
        }
        $courseIds = json_decode((string) ($article['attributes']['combo_course_in_blog']['value'] ?? ''), true);
        $courseIds = is_array($courseIds) ? array_values(array_filter(array_map('intval', $courseIds))) : [];
        $gallery = [];
        foreach ($article['images'] ?? [] as $image) {
            if (is_string($image) && $image && $image !== $current['image']) $gallery[] = $image;
        }
        return ['current' => $current, 'topic' => $topic, 'description' => $description,
            'html' => $content['html'], 'toc' => $content['toc'],
            'minutes' => max(1, (int) ceil(count($words) / 220)),
            'related' => array_slice($related, 0, 3), 'previous' => $previous, 'next' => $next,
            'faqs' => $faqs, 'course_ids' => $courseIds, 'gallery' => $gallery];
    }

    private function plain(string $html): string
    {
        $text = html_entity_decode(strip_tags($html), ENT_QUOTES | ENT_HTML5, 'UTF-8');
        return trim(preg_replace('/[\s\x{00A0}\x{200B}\x{FEFF}]+/u', ' ', $text) ?? '');
    }

    /** Remove pasted fonts/colors, retain semantic text and original anchors, make media responsive. */
    private function clean(string $html, bool $withToc = false): array
    {
        $result = ['html' => '', 'toc' => []];
        if (trim($html) === '') return $result;
        $dom = new \DOMDocument('1.0', 'UTF-8');
        $previous = libxml_use_internal_errors(true);
        $dom->loadHTML('<?xml encoding="utf-8" ?><div id="blog-prose-root">' . $html . '</div>', LIBXML_HTML_NOIMPLIED | LIBXML_HTML_NODEFDTD);
        libxml_clear_errors();
        libxml_use_internal_errors($previous);
        $root = $dom->getElementById('blog-prose-root');
        if (!$root) return $result;
        $xpath = new \DOMXPath($dom);
        $nodes = iterator_to_array($xpath->query('.//*', $root));
        foreach ($nodes as $node) {
            $tag = strtolower($node->nodeName);
            if (in_array($tag, ['script', 'style', 'object', 'embed', 'link', 'meta', 'form', 'input', 'button'], true)) {
                if ($node->parentNode) $node->parentNode->removeChild($node);
                continue;
            }
            foreach (['img', 'iframe', 'video'] as $mediaTag) {
                if ($tag !== $mediaTag) continue;
                $src = trim($node->getAttribute('src'));
                $lazySrc = trim($node->getAttribute('data-src'));
                if ($lazySrc && !preg_match('/^data:/i', $lazySrc) && (!$src || strpos($src, 'data:') === 0)) $node->setAttribute('src', $lazySrc);
            }
            // Keep valid image dimensions to reserve space before lazy images load.
            // Otherwise jumping to a heading can drift as images above it expand.
            $imageDimensions = $tag === 'img' && ctype_digit($node->getAttribute('width')) && ctype_digit($node->getAttribute('height'))
                && (int) $node->getAttribute('width') > 0 && (int) $node->getAttribute('height') > 0;
            foreach (iterator_to_array($node->attributes) as $attribute) {
                $name = strtolower($attribute->name);
                if ($imageDimensions && in_array($name, ['width', 'height'], true)) continue;
                if (in_array($name, ['style', 'class', 'face', 'size', 'width', 'height', 'align', 'data-src', 'srcset', 'sizes'], true) || strpos($name, 'on') === 0 || strpos($name, 'nh-') === 0) $node->removeAttribute($name);
            }
            foreach (['src', 'href'] as $name) {
                if (preg_match('/^\s*(?:javascript|vbscript|data):/i', $node->getAttribute($name))) $node->removeAttribute($name);
            }
            if ($tag === 'a') $node->setAttribute('rel', 'noopener noreferrer');
            if ($tag === 'iframe') {
                $node->setAttribute('loading', 'lazy');
                if (!$node->hasAttribute('title')) $node->setAttribute('title', 'Video trong bài viết MedUC');
                $node->setAttribute('allowfullscreen', '');
            }
            if ($tag === 'img') {
                if (!$node->getAttribute('src')) {
                    if ($node->parentNode) $node->parentNode->removeChild($node);
                    continue;
                }
                if (preg_match('/\.(?:mp4|webm|ogg)(?:[?#]|$)/i', $node->getAttribute('src'))) {
                    $video = $dom->createElement('video');
                    $video->setAttribute('src', $node->getAttribute('src'));
                    $video->setAttribute('controls', '');
                    $video->setAttribute('playsinline', '');
                    $video->setAttribute('preload', 'none');
                    if ($node->parentNode) $node->parentNode->replaceChild($video, $node);
                } else {
                    $node->setAttribute('loading', 'lazy');
                    $node->setAttribute('decoding', 'async');
                    if (preg_match('~(?:emoji\.php|/emoji/)~i', $node->getAttribute('src'))) {
                        $node->setAttribute('class', 'mbj-emoji');
                    } elseif ($imageDimensions) {
                        $width = (int) $node->getAttribute('width');
                        $height = (int) $node->getAttribute('height');
                        $node->setAttribute('style', '--mbj-image-width:' . $width . 'px;--mbj-image-ratio:' . $width . '/' . $height);
                    }
                }
            }
            if ($tag === 'table' && $node->parentNode) {
                $wrapper = $dom->createElement('div');
                $wrapper->setAttribute('class', 'mbj-table-scroll');
                $wrapper->setAttribute('tabindex', '0');
                $wrapper->setAttribute('role', 'region');
                $wrapper->setAttribute('aria-label', 'Bảng trong bài viết, có thể cuộn ngang');
                $node->parentNode->insertBefore($wrapper, $node);
                $wrapper->appendChild($node);
            }
            if ($tag === 'h1') {
                $heading = $dom->createElement('h2');
                foreach (iterator_to_array($node->attributes) as $attribute) $heading->setAttribute($attribute->name, $attribute->value);
                while ($node->firstChild) $heading->appendChild($node->firstChild);
                if ($node->parentNode) $node->parentNode->replaceChild($heading, $node);
            }
        }
        if ($withToc) {
            $headings = $xpath->query('.//h2', $root);
            if (!$headings->length) $headings = $xpath->query('.//h3', $root);
            foreach ($headings as $index => $heading) {
                $name = $this->plain($dom->saveHTML($heading));
                if ($name === '') continue;
                if (!$heading->getAttribute('id')) {
                    $id = 'blog-section-' . ($index + 1);
                    while ($dom->getElementById($id)) $id .= '-section';
                    $heading->setAttribute('id', $id);
                }
                $result['toc'][] = ['id' => $heading->getAttribute('id'), 'name' => $name];
            }
        }
        foreach ($root->childNodes as $child) $result['html'] .= $dom->saveHTML($child);
        return $result;
    }
}
