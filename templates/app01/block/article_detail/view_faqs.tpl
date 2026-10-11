{assign var = article_info value = []}
{if !empty($data_block.data)}
	{assign var = article_info value = $data_block.data}
{/if}
{if !empty($article_info)}
    {if !empty($article_info.attributes.cauhoithuonggap)}
        <div class="course-details-card">
            {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
                <div class="title-section-2">
                    <span>{$this->Block->getLocale('tieu_de', $data_extend)}</span>
                </div>
            {/if}
            
            {assign var = danhsachcauhoi value = $article_info.attributes.cauhoithuonggap.value|json_decode:1}
            
            <div class="accordion-style-1">
                <div class="edu-accordion" itemscope="" itemtype="https://schema.org/FAQPage">
                    {foreach from = $danhsachcauhoi key = key item = item}
        				<div class="edu-accordion-item" itemscope="" itemprop="mainEntity" itemtype="https://schema.org/Question">
                            <div class="edu-accordion-header" id="heading{$key}">
                                <a itemprop="name" href="#faq-collapse{$key}" class="edu-accordion-button {if ($key != 0)}collapsed{/if}" type="button" data-bs-toggle="collapse" data-bs-target="#faq-collapse{$key}" aria-expanded="{if ($key == 0)}true{else}false{/if}" aria-controls="faq-collapse{$key}">
                                    {if !empty($item.name_vi)}
                        			    {$item.name_vi}
                        			{/if}
                                </a>
                            </div>
                            <div itemscope="" itemprop="acceptedAnswer" itemtype="https://schema.org/Answer" id="faq-collapse{$key}" class="accordion-collapse collapse {if ($key == 0)}show{/if}" aria-labelledby="heading{$key}">
                                <div class="edu-accordion-body" itemprop="text">
                                    {if !empty($item.description_vi)}
                        			    {$item.description_vi}
                        			{/if}
                                </div>
                            </div>
                        </div>
        			{/foreach}
                </div>
            </div>
        </div>
    {/if}
{/if}