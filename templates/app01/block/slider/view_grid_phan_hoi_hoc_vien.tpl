{strip}
{if !empty($data_block)}
    <div class="rbt-course-action-bottom">
        <div class="read-more-btn">
            <a href="/khoa-hoc" class="edu-btn w-100 text-center btn-ani">
                Tìm Hiểu Khóa Học
            </a>
        </div>
    </div>
    
    <div class="student-testimonial py-60">
        <div class="inner-bg">
            {if !empty($data_extend['locale'][{LANGUAGE}]['anh_nen'])}
            	{$this->LazyLoad->renderImage([
            		'src' => "{$this->Utilities->replaceVariableSystem($this->Block->getLocale('anh_nen', $data_extend))}",
            		'delay' => 'all'
            	])}
            {/if}
        </div>
        <div class="container">
            <div class="row">
                <div class="col-12">
                    
                    {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
                        <div class="row">
                            <div class="col-lg-12">
                                <div class="section-title text-center mb--30" data-sal-delay="150" data-sal="slide-up" data-sal-duration="800">
                                    {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de_phu'])}
                                        <span class="pre-title">{$this->Block->getLocale('tieu_de_phu', $data_extend)}</span>
                                    {/if}
                                    <h3 class="title">{$this->Block->getLocale('tieu_de', $data_extend)}</h3>
                                </div>
                            </div>
                        </div>
                    {/if}
                    
                	<div class="row g-5 mt--10" data-sal="slide-up" data-sal-delay="400" data-sal-easing="ease-out-back" data-sal-duration="800">
                		{foreach from = $data_block item = slider}			
                			{assign var = image_source value = ''}
                			{if !empty($slider.image) && !empty($slider.image_source)}
                				{assign var = image_source value = $slider.image_source}
                			{/if}
                
                			{assign var = image_url value = ''}
                			{if !empty($slider.image) && $image_source == 'cdn'}
                				{assign var = image_url value = "{CDN_URL}{$slider.image}"}
                				{if !empty(DEVICE)}
                				    {assign var = image_url value = "{CDN_URL}{$this->Utilities->getThumbs($slider.image, 350)}"}
                				{/if}
                			{/if}
                
                			{if !empty($slider.image) && $image_source == 'template'}
                				{assign var = image_url value = "{$slider.image}"}
                				{if !empty(DEVICE)}
                				    {assign var = image_url value = "{$this->Utilities->getThumbs($slider.image, 350, 'template')}"}
                				{/if}
                			{/if}
                			
                			<div class="col-xl-4 col-lg-4 col-md-6 col-12 mt-0 mb-30">
                			    <div class="edu-gallery-grid-item grid-metro-item cat--1 cat--3">
                    			    <div nh-light-gallery>
                        			    <a {if !empty($slider.url)}href="https://www.youtube.com/watch?v={$slider.url}"{/if}>
                                            <div class="edu-gallery-grid">
                                                <div class="inner">
                                                    <div class="thumbnail">
                                                        <img class="w-100" nh-lazy="image" data-src="https://img.youtube.com/vi/{$slider.url}/sddefault.jpg" alt="{if !empty($slider.name)}{$slider.name}{/if}">
                                                    </div>
                                                </div>
                            
                                                <div class="zoom-icon">
                                                    <i class="icon-zoom-in-line"></i>
                                                </div>
                                                <div class="hover-action">
                                                    <div class="hover-content">
                                                        <div class="hover-text">
                                                            <p class="desc">
                                                                {if !empty($slider.description)}{$slider.description}{/if}
                                                            </p>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </a>
                                        <h6 class="title mt-5 text-center fs-16">{if !empty($slider.name)}{$slider.name}{/if}</h6>
                                    </div>
                                    {if !empty($slider.description_short)}
                                        <div class="text-center">
                                            <a href="{$slider.description_short}" class="edu-btn btn-small px-30 btn-ani" target="_blank">
                                                Tìm hiểu khoá học
                                            </a>
                                        </div>
                                    {/if}
                    			</div>
                			</div>
                		{/foreach}
                	</div>
                    
                    {if !empty($data_extend['locale'][{LANGUAGE}]['nut_bam'])}
                        <div class="text-center mt-80">
                            <div class="read-more-btn" data-sal-delay="450" data-sal="slide-up" data-sal-duration="800">
                                <a class="edu-btn btn-ani" href="{if !empty($data_extend['locale'][{LANGUAGE}]['link_nut_bam'])}{$this->Block->getLocale('link_nut_bam', $data_extend)}{/if}">
                                    {$this->Block->getLocale('nut_bam', $data_extend)|nl2br} <i class="icon-arrow-right-line-right"></i>
                                </a>
                            </div>
                        </div>
                    {/if}
                    
                </div>
            </div>
        </div>
    </div>
{/if}
{/strip}