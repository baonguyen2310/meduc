<?php
declare(strict_types=1);

namespace App\View\Helper;

use Cake\ORM\TableRegistry;
use Cake\View\Helper;

class BlogHelper extends Helper
{
    /** Both original blog trees, with published records only. No article content is copied or changed. */
    public function catalogue(int $categoryId, string $lang): array
    {
        $categories = TableRegistry::get('Categories')->getAll(ARTICLE, $lang);
        // The older Blog and newer Blog Môn Học categories describe the same subjects.
        $aliases = [117 => 93, 119 => 91, 118 => 92, 116 => 94, 115 => 95, 114 => 96];
        $order = [100, 93, 91, 92, 94, 95, 96];
        $topics = [];
        $categoryTopics = [];
        foreach ($categories as $id => $category) {
            if (empty($category['status']) || !in_array((int) $category['parent_id'], [45, 113], true)) continue;
            $topicId = $aliases[$id] ?? (int) $id;
            $canonical = $categories[$topicId] ?? $category;
            $name = preg_replace('/^Blog\s+/iu', '', (string) $canonical['name']);
            $topics[$topicId] = ['id' => $topicId, 'name' => $name, 'url' => $canonical['url'], 'count' => 0];
            $categoryTopics[(int) $id] = $topicId;
        }
        uksort($topics, function ($a, $b) use ($order) {
            $left = array_search($a, $order, true);
            $right = array_search($b, $order, true);
            return ($left === false ? 100 + $a : $left) <=> ($right === false ? 100 + $b : $right);
        });
        $articles = TableRegistry::get('Articles')->queryListArticles([
            'get_categories' => true,
            FILTER => [LANG => $lang, STATUS => 1, 'id_categories' => [45, 113]],
            SORT => [FIELD => 'created', SORT => DESC],
        ])->where(['Articles.draft' => 0])->toList();

        $items = [];
        foreach ($articles as $article) {
            $ids = [];
            foreach ($article['CategoriesArticle'] ?? [] as $membership) {
                $id = (int) $membership['category_id'];
                if (isset($categoryTopics[$id])) $ids[] = $categoryTopics[$id];
            }
            $ids = array_values(array_unique($ids));
            foreach ($ids as $id) $topics[$id]['count']++;
            $created = (int) ($article['created'] ?? 0);
            $items[] = [
                'id' => (int) $article['id'],
                'name' => $this->plain((string) $article['ArticlesContent']['name']),
                'summary' => $this->plain((string) $article['ArticlesContent']['description'], 235),
                'image' => (string) ($article['image_avatar'] ?? ''),
                'url' => (string) $article['Links']['url'],
                'created' => $created,
                'date' => $created > 0 ? date('d.m.Y', $created) : '',
                'datetime' => $created > 0 ? date('Y-m-d', $created) : '',
                'topics' => $ids,
                'topic_ids' => implode(' ', $ids),
                'topic_name' => $ids ? $topics[$ids[0]]['name'] : 'Góc học tập',
                'featured' => !empty($article['featured']),
            ];
        }
        $active = $categoryTopics[$categoryId] ?? 0;
        $selection = array_values(array_filter($items, function ($item) use ($active) {
            return !$active || in_array($active, $item['topics'], true);
        }));
        // Prefer an editor-marked article; otherwise use the newest article with a cover.
        $lead = [];
        foreach ($selection as $item) {
            if (empty($item['image'])) continue;
            if (!$lead) $lead = $item;
            if ($item['featured']) { $lead = $item; break; }
        }
        return ['items' => $items, 'topics' => $topics, 'active' => $active, 'lead' => $lead,
            'selected_count' => count($selection), 'title' => $active ? $topics[$active]['name'] : ''];
    }

    private function plain(string $html, int $limit = 0): string
    {
        $html = preg_replace('/<(script|style)\b[^>]*>.*?<\/\1>/is', '', $html) ?? '';
        $text = html_entity_decode(strip_tags($html), ENT_QUOTES | ENT_HTML5, 'UTF-8');
        $text = trim(preg_replace('/[\s\x{00A0}\x{200B}\x{FEFF}]+/u', ' ', $text) ?? '');
        if ($limit && mb_strlen($text) > $limit) $text = rtrim(mb_substr($text, 0, $limit - 1)) . '…';
        return $text;
    }
}
