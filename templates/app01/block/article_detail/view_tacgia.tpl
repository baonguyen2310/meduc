{assign var = article_info value = []}
{if !empty($data_block.data)}
	{assign var = article_info value = $data_block.data}
{/if}
{if !empty($article_info)}
    {if !empty($article_info.attributes.tacgia.detail)}
	    <div class="box-author">
            <div class="inner-info">
                <div class="inner-avatar">
                    {$this->LazyLoad->renderImage([
                        'src' => "{CDN_URL}{$article_info.attributes.tacgia.detail.image_avatar}", 
                        'alt' => "{$article_info.attributes.tacgia.detail.ArticlesContent.name}", 
                        'class' => 'img-fluid'
                    ])}
                </div>
                <div class="inner-text">
                    {if !empty($article_info.attributes.tacgia.detail.ArticlesContent.name)}
                        <h3 class="inner-name">
                            {$article_info.attributes.tacgia.detail.ArticlesContent.name}
                        </h3>
                    {/if}
                    {if !empty($data_extend['locale'][{LANGUAGE}]['tac_gia'])}
                        <div class="inner-author">
                        	{$this->Block->getLocale('tac_gia', $data_extend)|nl2br}
                        </div>
                    {/if}
                </div>
            </div>
            {if !empty($article_info.attributes.tacgia.detail.ArticlesContent.description)}
                <div class="inner-desc">
                    {$article_info.attributes.tacgia.detail.ArticlesContent.description}
                </div>
            {/if}
        </div>
    {/if}
{/if}