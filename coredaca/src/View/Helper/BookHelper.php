<?php
declare(strict_types=1);

namespace App\View\Helper;

use Cake\View\Helper;

class BookHelper extends Helper
{
    /** Detail-helper products carry prices on their items; catalogue cards expect the formatted first-item price. */
    public function asCatalog(array $products): array
    {
        $rate = defined('CURRENCY_RATE') && CURRENCY_RATE > 0 ? CURRENCY_RATE : 1;
        foreach ($products as &$product) {
            $item = $product['items'][0] ?? [];
            $product['price'] = isset($item['price']) ? round((float) $item['price'] / $rate, 2) : 0;
            $product['price_special'] = isset($item['price_special']) ? round((float) $item['price_special'] / $rate, 2) : 0;
            $product['apply_special'] = !empty($item['apply_special']);
        }
        unset($product);
        return $products;
    }

    /** Presentation data only; product content, prices and catalogue memberships remain in the original CMS. */
    public function prepareDetail(array $product, bool $checkQuantity = false): array
    {
        $name = (string) ($product['name'] ?? '');
        $facts = [];
        if (preg_match('/(\d+)\s*tập/iu', $name, $match)) $facts['Số tập'] = $match[1] . ' tập';
        if (preg_match('/song\s*ngữ/iu', $name)) $facts['Ngôn ngữ'] = 'Song ngữ';
        elseif (preg_match('/tiếng\s*việt/iu', $name)) $facts['Ngôn ngữ'] = 'Tiếng Việt';
        elseif (preg_match('/tiếng\s*anh/iu', $name)) $facts['Ngôn ngữ'] = 'Tiếng Anh';
        if (preg_match('/đen\s*trắng/iu', $name)) $facts['Bản in'] = 'In đen trắng';
        elseif (preg_match('/(?:in|full)\s*màu/iu', $name)) $facts['Bản in'] = 'In màu';
        if (preg_match('/\b([AB][3456])\b/iu', $name, $match)) $facts['Khổ sách'] = strtoupper($match[1]);

        $attributes = $product['attributes'] ?? [];
        $labels = ['motangan' => 'Giới thiệu', 'thongtinchitiet' => 'Review sách', 'videoreview' => 'Video review', 'thongtinsach' => 'Thông tin sách', 'huongdansudung' => 'Hướng dẫn', 'thongsokythuat' => 'Thông số'];
        $sections = [];
        foreach ($labels as $code => $label) {
            $html = $this->cleanContent((string) ($attributes[$code]['value'] ?? ''));
            if (!$this->hasContent($html)) continue;
            if ($code === 'videoreview' && !preg_match('/<(?:video|iframe)\b/i', $html)) $label = 'Đọc thêm';
            $sections[] = ['code' => $code, 'label' => $label, 'html' => $html];
        }
        $summary = html_entity_decode(strip_tags((string) ($attributes['motangan']['value'] ?? '')), ENT_QUOTES | ENT_HTML5, 'UTF-8');
        $summary = trim(preg_replace('/\s+/u', ' ', str_replace("\xc2\xa0", ' ', $summary)) ?? '');
        if (mb_strlen($summary) > 230) $summary = mb_substr($summary, 0, 227) . '…';

        $items = [];
        foreach (($product['items'] ?? []) as $index => $item) {
            $base = (float) ($item['price'] ?? 0);
            $current = !empty($item['apply_special']) && !empty($item['price_special']) ? (float) $item['price_special'] : $base;
            $maximum = $checkQuantity ? max(0, (int) ($item['quantity_available'] ?? 0)) : null;
            $items[] = [
                'id' => (int) $item['id'],
                'label' => $item['name'] ?? ($item['code'] ?? ('Ấn bản ' . ($index + 1))),
                'price' => $base,
                'current' => $current,
                'discount' => $base > $current && $current > 0 ? (int) round(($base - $current) * 100 / $base) : 0,
                'maximum' => $maximum,
                'available' => $current > 0 && ($maximum === null || $maximum > 0),
                'cart' => [
                    'id' => (int) $item['id'], 'name' => $name,
                    'image' => $item['images'][0] ?? ($product['all_images'][0] ?? ''),
                    'price' => $base, 'price_special' => $current, 'quantity' => 1,
                    'url' => '/' . ltrim((string) ($product['url'] ?? ''), '/'),
                ],
            ];
        }
        $promotion = $this->cleanContent((string) ($attributes['khuyenmaiuudai']['value'] ?? ''));
        return ['facts' => $facts, 'summary' => $summary, 'sections' => $sections, 'items' => $items, 'promotion' => $this->hasContent($promotion) ? $promotion : ''];
    }

    private function hasContent(string $html): bool
    {
        $text = html_entity_decode(strip_tags($html), ENT_QUOTES | ENT_HTML5, 'UTF-8');
        $text = preg_replace('/[\s\x{200B}\x{FEFF}]+/u', '', $text);
        return $text !== '' || (bool) preg_match('/<(?:img|video|iframe)\b/i', $html);
    }

    /** Remove pasted typography and turn legacy MP4 image placeholders into native video players. */
    public function cleanContent(string $html): string
    {
        if (trim($html) === '') return '';
        $dom = new \DOMDocument('1.0', 'UTF-8');
        $previous = libxml_use_internal_errors(true);
        $dom->loadHTML('<?xml encoding="utf-8" ?><div id="book-content-root">' . $html . '</div>', LIBXML_HTML_NOIMPLIED | LIBXML_HTML_NODEFDTD);
        libxml_clear_errors();
        libxml_use_internal_errors($previous);
        $nodes = iterator_to_array($dom->getElementsByTagName('*'));
        foreach ($nodes as $node) {
            if (in_array(strtolower($node->nodeName), ['script', 'style', 'object', 'embed', 'link', 'meta'], true)) {
                if ($node->parentNode) $node->parentNode->removeChild($node);
                continue;
            }
            foreach (iterator_to_array($node->attributes) as $attribute) {
                $attributeName = strtolower($attribute->name);
                if (in_array($attributeName, ['style', 'class', 'id', 'face', 'size', 'width', 'height', 'align'], true) || strpos($attributeName, 'on') === 0) $node->removeAttribute($attribute->name);
            }
            foreach (['src', 'href'] as $attributeName) {
                if ($node->hasAttribute($attributeName) && preg_match('/^\s*(?:javascript|vbscript|data):/i', $node->getAttribute($attributeName))) $node->removeAttribute($attributeName);
            }
            if ($node->nodeName === 'a') $node->setAttribute('rel', 'noopener noreferrer');
            if ($node->nodeName === 'iframe') {
                $node->setAttribute('loading', 'lazy');
                if (!$node->hasAttribute('title')) $node->setAttribute('title', 'Video review sách');
            }
            if ($node->nodeName !== 'img') continue;
            $src = $node->getAttribute('src');
            if (preg_match('/\.(?:mp4|webm|ogg)(?:[?#]|$)/i', $src)) {
                $video = $dom->createElement('video');
                $video->setAttribute('controls', '');
                $video->setAttribute('playsinline', '');
                $video->setAttribute('preload', 'none');
                $video->setAttribute('src', $src);
                if ($node->parentNode) $node->parentNode->replaceChild($video, $node);
            } else {
                $node->setAttribute('loading', 'lazy');
                $node->setAttribute('decoding', 'async');
                if (preg_match('~(?:emoji\.php|/emoji/)~i', $src)) $node->setAttribute('class', 'mbd-emoji');
            }
        }
        $root = $dom->getElementsByTagName('div')->item(0);
        if (!$root) return '';
        $result = '';
        foreach ($root->childNodes as $child) $result .= $dom->saveHTML($child);
        return $result;
    }
}
