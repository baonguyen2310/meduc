{strip}
<article class="article-item clearfix">
    <div class="inner-content">
        {if !empty($article.name)}   
            <h4 class="article-title">
                <a href="{if !empty($article.url)}{$this->Utilities->checkInternalUrl($article.url)}{/if}">
                    {$article.name|escape}
                </a>
            </h4>  
        {/if}

        <div class="article-entry-info">
            {if !empty($article.created)}
                <li><i class="icon-calendar-2-line"></i> {$this->Utilities->convertIntgerToDateString($article.created)}</li>
            {/if}
            {if !empty($article.attributes.thoigianlambai.value)}
                <li><i class="fa-regular fa-clock"></i> {$article.attributes.thoigianlambai.value} phút</li>
            {/if}
            {if !empty($article.attributes.danhsachcauhoi.value)}
                {assign danhsachcauhoi value = $article.attributes.danhsachcauhoi.value|json_decode:1}
                <li><i class="fa-regular fa-circle-question"></i> {$danhsachcauhoi|@count} câu hỏi</li>
            {/if}
        </div>
    </div>  
</article>
{/strip}