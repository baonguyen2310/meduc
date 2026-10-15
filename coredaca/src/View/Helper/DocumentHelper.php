<?php
declare(strict_types=1);

namespace App\View\Helper;

use Cake\View\Helper;
use Cake\ORM\TableRegistry;
use Cake\Utility\Text;

class DocumentHelper extends Helper
{
    /** Read the existing document articles; no snapshot, new taxonomy or file access rules. */
    public function getCatalog(array $categories, int $activeCategory, string $lang): array
    {
        $table = TableRegistry::get('Articles');
        $query = $table->queryListArticles([
            'get_categories' => true,
            FILTER => [LANG => $lang, STATUS => 1, 'id_categories' => [48]],
            SORT => [FIELD => 'position', SORT => DESC]
        ])->where(['Articles.draft' => 0]);
        $yearIds = [75 => '1', 122 => '2', 123 => '3', 124 => '4'];
        $categoryMap = [];
        foreach ($categories as $category) $categoryMap[(int) $category['id']] = $category;
        $documents = $subjects = $hero = [];
        $yearCounts = ['1' => 0, '2' => 0, '3' => 0, '4' => 0, 'other' => 0];
        foreach ($query as $row) {
            $article = $table->formatDataArticleDetail($row, $lang);
            $name = (string) ($article['name'] ?? '');
            if ($name === '' || empty($article['url'])) continue;
            $memberships = array_keys($article['categories'] ?? []);
            // Exclude records whose only membership is an inactive document category.
            if (!in_array(48, $memberships) && !array_intersect($memberships, array_keys($categoryMap))) continue;
            $years = [];
            foreach ($yearIds as $id => $year) if (in_array($id, $memberships)) $years[] = $year;
            $title = $name;
            $subject = '';
            if (preg_match('/^\[([^\]]+)\]\s*(.+)$/u', $name, $match)) {
                $title = trim($match[2]);
                $subject = trim(preg_replace('/^Năm\s*[1-4]\s*[-–—]?\s*/iu', '', $match[1]));
                if (!$years && preg_match('/^Năm\s*([1-4])\b/iu', $match[1], $yearMatch)) $years[] = $yearMatch[1];
            }
            foreach ($memberships as $id) {
                if ($id === 48 || isset($yearIds[$id]) || !isset($categoryMap[$id])) continue;
                if ($subject === '') $subject = trim(preg_replace('/^Tài\s*liệu\s*/iu', '', $categoryMap[$id]['name']));
            }
            if ($subject === '') $subject = 'Tài liệu khác';
            $subjectKey = Text::slug(mb_strtolower($subject, 'UTF-8'), '-');
            if (!isset($subjects[$subjectKey])) $subjects[$subjectKey] = ['key' => $subjectKey, 'name' => $subject, 'count' => 0];
            $subjects[$subjectKey]['count']++;
            $files = array_values(array_filter($article['files'] ?? [], 'is_string'));
            $formats = [];
            foreach ($files as $file) {
                $extension = strtoupper(pathinfo((string) parse_url(rawurldecode($file), PHP_URL_PATH), PATHINFO_EXTENSION));
                if (in_array($extension, ['PDF', 'DOC', 'DOCX', 'PPT', 'PPTX', 'ZIP', 'RAR', 'XLS', 'XLSX'])) $formats[$extension] = $extension;
            }
            $summary = html_entity_decode(strip_tags((string) ($article['description'] ?? '')), ENT_QUOTES | ENT_HTML5, 'UTF-8');
            $summary = trim(preg_replace('/[\s\x{00A0}\x{200B}]+/u', ' ', $summary) ?? '');
            if (mb_strlen($summary) > 175) $summary = mb_substr($summary, 0, 172) . '…';
            $created = (int) $row['created'];
            $document = [
                'id' => (int) $article['id'], 'name' => $name, 'title' => $title,
                'subject' => $subject, 'subject_key' => $subjectKey,
                'category_ids' => implode(' ', $memberships),
                'years' => implode(' ', $years ?: ['other']),
                'year_label' => $years ? 'Năm ' . implode(', ', $years) : 'Tài liệu Y khoa',
                'summary' => $summary, 'image' => $article['image_avatar'] ?? '',
                'url' => $article['url'], 'file_count' => count($files),
                'formats' => implode(' / ', $formats),
                'date' => $created > 0 ? date('d/m/Y', $created) : '',
                'date_iso' => $created > 0 ? date('Y-m-d', $created) : '',
                'created' => $created
            ];
            $documents[] = $document;
            // Navigation counts match the original category URLs exactly.
            $assignedYears = [];
            foreach ($yearIds as $id => $year) if (in_array($id, $memberships)) $assignedYears[] = $year;
            foreach ($assignedYears ?: ['other'] as $year) $yearCounts[$year]++;
            if (!empty($document['image'])) {
                foreach ($years as $year) if (!isset($hero[$year])) $hero[$year] = $document;
            }
        }
        $total = count($documents);
        if ($activeCategory !== 48 && isset($categoryMap[$activeCategory])) {
            $documents = array_values(array_filter($documents, function ($document) use ($activeCategory) {
                return in_array((string) $activeCategory, explode(' ', $document['category_ids']), true);
            }));
            $subjects = [];
            foreach ($documents as $document) {
                $key = $document['subject_key'];
                if (!isset($subjects[$key])) $subjects[$key] = ['key' => $key, 'name' => $document['subject'], 'count' => 0];
                $subjects[$key]['count']++;
            }
        }
        uasort($subjects, function ($a, $b) { return strnatcasecmp(Text::slug($a['name']), Text::slug($b['name'])); });
        ksort($hero);
        return ['total' => $total, 'documents' => $documents, 'subjects' => $subjects, 'year_counts' => $yearCounts,
            'hero' => array_slice(array_values($hero), 0, 4), 'category' => $categoryMap[$activeCategory] ?? null];
    }
}
