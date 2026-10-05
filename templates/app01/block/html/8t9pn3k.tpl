{strip}<div class="edu-breadcrumb-area breadcrumb-style-1 ptb--60 ptb_md--40 ptb_sm--40 bg-image">
    <div class="container eduvibe-animated-shape">
        <div class="row">
            <div class="col-lg-12">
                <div class="breadcrumb-inner text-start">
                    <div class="page-title">
                        {foreach from = $breadcrumb item = item name = breadcrumb_each}
                            {if $smarty.foreach.breadcrumb_each.last}
                                <h3 class="title">{$item.name|escape}</h3>
                            {/if}
                        {/foreach}
                    </div>
                    <nav class="edu-breadcrumb-nav">
                        <ol class="edu-breadcrumb d-flex justify-content-start liststyle">
                            {if !empty($breadcrumb)}
                                <li class="breadcrumb-item"><a href="/">Trang chủ</a></li>
                        	    {foreach from = $breadcrumb item = item name = breadcrumb_each}
                        	        {if !$smarty.foreach.breadcrumb_each.last}
                        	            {if !empty($item.url)}
                        	                <li class="separator"><i class="ri-arrow-drop-right-line"></i></li>
                                            <li class="breadcrumb-item">
                                                <a href="{$this->Utilities->checkInternalUrl($item.url)}">
                                                    {$item.name|escape|truncate:50:" ..."}
                                                </a>
                                            </li>
                        	            {/if}
                        	        {else}
                        	            <li class="separator"><i class="ri-arrow-drop-right-line"></i></li>
                                        <li class="breadcrumb-item">
                                            <a href="{$this->Utilities->checkInternalUrl($item.url)}">
                                                {$item.name|escape|truncate:50:" ..."}
                                            </a>
                                        </li>
                        	        {/if}
                        	    {/foreach}
                        	{/if}
                            {*<li class="breadcrumb-item"><a href="index.html">Home</a></li>
                            <li class="separator"><i class="ri-arrow-drop-right-line"></i></li>
                            <li class="breadcrumb-item active" aria-current="page">Blog Details</li>*}
                        </ol>
                    </nav>
                </div>
            </div>
        </div>

        {*<div class="shape-dot-wrapper shape-wrapper d-xl-block d-none">
            <div class="shape-dot-wrapper shape-wrapper d-xl-block d-none">
                <div class="shape-image shape-image-1">
                    <img src="{URL_TEMPLATE}assets/eduvibe/images/shapes/shape-11-07.png" alt="Shape Thumb">
                </div>
                <div class="shape-image shape-image-2">
                    <img src="{URL_TEMPLATE}assets/eduvibe/images/shapes/shape-01-02.png" alt="Shape Thumb">
                </div>
                <div class="shape-image shape-image-3">
                    <img src="{URL_TEMPLATE}assets/eduvibe/images/shapes/shape-03.png" alt="Shape Thumb">
                </div>
                <div class="shape-image shape-image-4">
                    <img src="{URL_TEMPLATE}assets/eduvibe/images/shapes/shape-13-12.png" alt="Shape Thumb">
                </div>
                <div class="shape-image shape-image-5">
                    <img src="{URL_TEMPLATE}assets/eduvibe/images/shapes/shape-36.png" alt="Shape Thumb">
                </div>
                <div class="shape-image shape-image-6">
                    <img src="{URL_TEMPLATE}assets/eduvibe/images/shapes/shape-05-07.png" alt="Shape Thumb">
                </div>
            </div>
        </div>*}
        
        {if !empty($data_extend['locale'][{LANGUAGE}]['icon_linh_vat'])}
            <div class="inner-icon-logo">
                {$this->LazyLoad->renderImage([
            		'src' => "{$this->Utilities->replaceVariableSystem($this->Block->getLocale('icon_linh_vat', $data_extend))}", 
            		'delay' => 'all'
            	])}
            </div>
        {/if}
    </div>
</div>{/strip}