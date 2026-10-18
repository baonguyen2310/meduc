<?php
declare(strict_types=1);
namespace App\Lib;

/** Markdown and existing rich text share one sanitized explanation format. */
final class QuizExplanation
{
    private static $parser;
    private static $purifier;

    public static function render($value): string
    {
        $text = trim(str_replace(["\r\n", "\r"], "\n", (string)$value));
        if ($text === '') return '';
        $hasHtml = preg_match('/<\/?[a-z][^>]*>/i', $text) === 1;
        if (!$hasHtml && !self::hasMarkdown($text)) {
            return implode("\n", array_map(static function ($paragraph) {
                return '<p>' . nl2br(htmlspecialchars($paragraph, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'), false) . '</p>';
            }, preg_split('/\n[ \t]*\n+/', $text)));
        }
        $html = self::parser()->text($text);
        if ($hasHtml && self::hasMarkdown($text)) $html = self::embedded($html);
        return self::purifier()->purify($html);
    }

    private static function hasMarkdown(string $text): bool
    {
        return preg_match('/[*_`~|]|\[[^\]\r\n]+\]|(?:^|\n)[ \t]{0,3}(?:#{1,6}\s|[-+]\s|\d+\.\s|>|-{3,}(?:\s|$))/u', $text) === 1;
    }

    private static function parser(): \Parsedown
    {
        if (!self::$parser) {
            require_once __DIR__ . '/ThirdParty/Parsedown/Parsedown.php';
            self::$parser = new \Parsedown();
            // Existing HTML is retained, then restricted by HTMLPurifier below.
            self::$parser->setSafeMode(false)->setBreaksEnabled(true);
        }
        return self::$parser;
    }

    private static function purifier(): \HTMLPurifier
    {
        if (!self::$purifier) {
            $config = \HTMLPurifier_Config::createDefault();
            $config->set('HTML.Allowed', 'p,br,strong,b,em,i,u,s,del,sub,sup,h1,h2,h3,h4,h5,h6,ul,ol[start],li,blockquote,pre,code,hr,a[href|title],img[src|alt|title|width|height],table,thead,tbody,tfoot,tr,th[colspan|rowspan],td[colspan|rowspan],div,span');
            $config->set('URI.AllowedSchemes', ['http' => true, 'https' => true, 'mailto' => true]);
            $config->set('HTML.Nofollow', true);
            $config->set('Cache.DefinitionImpl', null);
            self::$purifier = new \HTMLPurifier($config);
        }
        return self::$purifier;
    }

    /** Source Markdown may be inside a paragraph saved by an older HTML editor. */
    private static function embedded(string $html): string
    {
        $previous = libxml_use_internal_errors(true);
        try {
            $dom = self::document($html);
            $xpath = new \DOMXPath($dom);
            $nodes = [];
            foreach ($xpath->query('//*[@id="explanation-root"]//*[self::p or self::li or self::td or self::th]') as $node) $nodes[] = $node;
            foreach ($nodes as $node) {
                if (!$node->parentNode || !self::hasMarkdown($node->textContent)) continue;
                if ($xpath->query('ancestor::pre|ancestor::code', $node)->length) continue;
                if ($xpath->query('./p|./div|./ul|./ol|./table|./pre|./blockquote', $node)->length) continue;
                $inner = '';
                foreach ($node->childNodes as $child) $inner .= $dom->saveHTML($child);
                $rendered = self::document(self::parser()->text($inner));
                $root = $rendered->getElementById('explanation-root');
                if (!$root) continue;
                if ($node->nodeName === 'p') {
                    foreach (iterator_to_array($root->childNodes) as $child) $node->parentNode->insertBefore($dom->importNode($child, true), $node);
                    $node->parentNode->removeChild($node);
                } else {
                    while ($node->firstChild) $node->removeChild($node->firstChild);
                    foreach (iterator_to_array($root->childNodes) as $child) $node->appendChild($dom->importNode($child, true));
                }
            }
            $result = '';
            $root = $dom->getElementById('explanation-root');
            if ($root) foreach ($root->childNodes as $child) $result .= $dom->saveHTML($child);
            return $result;
        } finally {
            libxml_clear_errors();
            libxml_use_internal_errors($previous);
        }
    }

    private static function document(string $html): \DOMDocument
    {
        $dom = new \DOMDocument('1.0', 'UTF-8');
        $dom->loadHTML('<?xml encoding="utf-8" ?><div id="explanation-root">' . $html . '</div>', LIBXML_NONET);
        return $dom;
    }
}
