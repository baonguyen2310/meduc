{strip}
<li class="article-link">
    <a href="{if !empty($article.url)}{$this->Utilities->checkInternalUrl($article.url)}{/if}">
        {$article.name|escape}
    </a>
</li>
{/strip}