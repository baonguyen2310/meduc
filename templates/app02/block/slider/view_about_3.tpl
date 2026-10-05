{if !empty($data_block)}
    <div class="about-intro about-intro-3">
        <div class="row align-items-center">
            <div class="col-lg-6 col-md-6 col-sm-12">
            	{if !empty($data_extend['locale'][{LANGUAGE}]['hinh_anh'])}
    			    <img class="inner-image" src="{$this->Utilities->replaceVariableSystem($this->Block->getLocale('hinh_anh', $data_extend))}" alt="#" />
    			{/if}
            </div>
            <div class="col-lg-6 col-md-6 col-sm-12">
            	<div class="inner-content">
            	    {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
            			<h3 class="inner-title">
            			    {$this->Block->getLocale('tieu_de', $data_extend)|nl2br}
            			</h3>
        			{/if}
        			<div class="inner-testimonials">
            			<div nh-owl-slick="{if !empty($data_extend.slider)}{htmlentities($data_extend.slider|@json_encode)}{/if}">
                			{foreach from = $data_block item = slider}
                    		    <div class="item {if !empty($slider.class_item)}{$slider.class_item}{/if}">
                    		        <div class="inner-item">
                    		            {if !empty($slider.name)}
                        				    <div class="inner-item-name">{$slider.name}</div>
                        				{/if}
                        				{if !empty($slider.description)}
                        				    <div class="inner-item-position">{$slider.description}</div>
                        				{/if}
                        				{if !empty($slider.description_short)}
                        				    <p class="inner-item-desc">{$slider.description_short}</p>
                        				{/if}
                    		        </div>
                    			</div>
                			{/foreach}
                		</div>
            		</div>
            		<div class="inner-social">
            		    {assign website_info value = $this->Setting->getWebsiteInfo()}
            			<ul class="list-unstyled list-social d-flex flex-wrap mb-15">
                            {if !empty($website_info.facebook)}
                                <li>
                                    <a href="https://facebook.com/{$website_info.facebook}" target="_blank">
                                        <i class="fa-brands fa-facebook-f"></i>
                                    </a>
                                </li>
                            {/if}
                            {if !empty($website_info.tiktok)}
                                <li>
                                    <a href="https://tiktok.com/{$website_info.tiktok}" target="_blank">
                                        <i class="fa-brands fa-tiktok"></i>
                                    </a>
                                </li>
                            {/if}
                            {if !empty($website_info.whatsapp)}
                                <li>
                                    <a href="https://wa.me/{$website_info.whatsapp}" target="_blank">
                                        <i class="fa-brands fa-whatsapp"></i>
                                    </a>
                                </li>
                            {/if}
                            {if !empty($website_info.instagram)}
                                <li>
                                    <a href="https://instagram.com/{$website_info.instagram}" target="_blank">
                                        <i class="fa-brands fa-instagram"></i>
                                    </a>
                                </li>
                            {/if}
                            {if !empty($website_info.linkedin)}
                                <li>
                                    <a href="https://linkedin.com/in/{$website_info.linkedin}" target="_blank">
                                        <i class="fa-brands fa-linkedin-in"></i>
                                    </a>
                                </li>
                            {/if}
                            {if !empty($website_info.twitter)}
                                <li>
                                    <a href="https://twitter.com/{$website_info.twitter}" target="_blank">
                                        <i class="fa-brands fa-twitter"></i>
                                    </a>
                                </li>
                            {/if}
                            {if !empty($website_info.youtube)}
                                <li>
                                    <a href="https://youtube.com/c/{$website_info.youtube}" target="_blank">
                                        <i class="fa-brands fa-youtube"></i>
                                    </a>
                                </li>
                            {/if}
                        </ul>
            		</div>
            	</div>
            </div>
        </div>
    </div>
{/if}