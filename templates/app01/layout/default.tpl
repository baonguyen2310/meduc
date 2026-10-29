<!DOCTYPE html>
<html lang="{LANGUAGE}" csrf-token="{$this->getRequest()->getAttribute('csrfToken')}">
<head>
    {assign var = title value = ""}
    {if !empty($seo_info.title)}
        {assign var = title value = "{$seo_info.title}"}
    {/if}
    {if !empty($title_for_layout)}
        {assign var = title value = "{$title_for_layout}"}
    {/if}

    <title>{$title}</title>

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"/>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">

    <meta name="description" content="{if !empty($seo_info.description)}{$seo_info.description}{/if}" />
    <meta name="keywords" content="{if !empty($seo_info.keywords)}{$seo_info.keywords}{/if}" />
    
    <link rel="canonical" href="{$this->Utilities->getUrlPath()}">
    <link rel="alternate" hreflang="{LANGUAGE}" href="{$this->Utilities->getUrlCurrent()}" />

    <!-- Twitter Card data -->
    <meta name="twitter:card" content="website">
    <meta name="twitter:site" content="{if !empty($seo_info.site_name)}{$seo_info.site_name}{/if}">
    <meta name="twitter:title" content="{$title}">
    <meta name="twitter:description" content="{if !empty($seo_info.description)}{$seo_info.description}{/if}">
    <meta name="twitter:image" content="{if !empty($seo_info.image)}{CDN_URL}{$seo_info.image}{/if}">

    <!-- Open Graph data -->
    <meta property="og:type" content="website">
    <meta property="og:site_name" content="{if !empty($seo_info.site_name)}{$seo_info.site_name}{/if}">
    <meta property="og:title" content="{$title}">
    <meta property="og:url" content="{$this->Utilities->getUrlCurrent()}">
    <meta property="og:image" content="{if !empty($seo_info.image)}{CDN_URL}{$seo_info.image}{/if}">
    <meta property="og:description" content="{if !empty($seo_info.description)}{$seo_info.description}{/if}">
    
    <meta http-equiv="x-dns-prefetch-control" content="on">
    <link rel="dns-prefetch" href="{CDN_URL}">
    
    {*<link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">*}
    <link href="/templates/{CODE_TEMPLATE}/assets/css/fonts.css" rel="stylesheet">
    {*<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.1.2/css/all.min.css" integrity="sha512-1sCRPdkRXhBV2PBLUdRb4tMg1w2YPf37qatUFeS7zlBy7jJI8Lf4VHwWfZZfpXtYSLy85pkm9GaYVYMfw5BC1A==" crossorigin="anonymous" referrerpolicy="no-referrer" />*}
    
    {assign website_info value = $this->Setting->getWebsiteInfo()}
    <link href="{if !empty($website_info.favicon)}{$this->Utilities->getWebsiteImageUrl($website_info.favicon)|escape}{else}/favicon.ico{/if}" rel="icon" type="{if !empty($website_info.favicon) && substr($website_info.favicon, -4) == '.svg'}image/svg+xml{else}image/x-icon{/if}"/>
    {$this->element('layout/css', [], $this->Setting->getConfigCacheView('css', {LAYOUT}))}

    {* Every page whose layout has a header gets the new header instead of the database header rows. *}
    {$use_header_v2 = !empty($page_code) && !empty($structure[{HEADER}])}
    {if $use_header_v2}
        <script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/theme-init.js?v=20261014"></script>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;700&display=swap" rel="stylesheet">
        <link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/header.css?v=20261029-account-menu-2" rel="stylesheet">
        <script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/header.js?v=20261018-1" defer></script>
        <link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/action-bar.css?v=20261014" rel="stylesheet">
        <script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/action-bar.js?v=20261014" defer></script>
        <link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/footer.css?v=20261021-1" rel="stylesheet">
    {/if}

    <link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/course-price-cart.css?v=20261022-8" rel="stylesheet">
    <script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/course-price-cart.js?v=20261029-quiz-url" defer></script>
    <script src="/bang-bao-gia/lien-ket.js" defer></script>

    {* The sign-in dialog is present on every page, so its styles are shared. *}
    <link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/auth.css?v=20261021-7" rel="stylesheet">
    <script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/auth.js?v=20261029-avatar" defer></script>

    {assign var = embed_code value = []}
    {if !empty($data_init.embed_code)}
        {assign var = embed_code value = $data_init.embed_code}
    {/if}

    {if !empty($embed_code.head) && empty($embed_code.time_delay)}
        {$embed_code.head}
    {/if}
    
    {*<link href="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.6.347/pdf_viewer.min.css" rel="stylesheet" type="text/css" />*}
</head>

<body class="{if !empty(DEVICE)}is-mobile{/if} {if !empty(PAGE_TYPE == 'home')}home{/if} {if $use_header_v2}meduc-header-v2{/if}">
    {if !empty($embed_code.top_body) && empty($embed_code.time_delay)}
        {$embed_code.top_body}
    {/if}

    {assign var = page_structure value = $structure}
    {* With the new header, the database header and footer rows give way to header_v2 and footer_v2.
       Only the footer row holding the floating contact button (block 5pjvim3) is kept. *}
    {assign var = kept_footer_rows value = []}
    {if $use_header_v2}
        {$this->element('layout/header_v2')}

        {assign var = page_structure value = []}
        {if !empty($structure)}
            {foreach from = $structure item = rows key = type}
                {if $type == {FOOTER}}
                    {foreach from = $rows item = row}
                        {$keep_row = false}
                        {if !empty($row.columns)}
                            {foreach from = $row.columns item = column}
                                {if !empty($column.blocks) && in_array('5pjvim3', $column.blocks)}{$keep_row = true}{/if}
                            {/foreach}
                        {/if}
                        {if $keep_row}{$kept_footer_rows[] = $row}{/if}
                    {/foreach}
                {elseif $type != {HEADER}}
                    {$page_structure[$type] = $rows}
                {/if}
            {/foreach}
        {/if}
    {/if}

    {if !empty($page_code) && !empty($page_structure)}
        {assign var = page_cache_options value = []}
        {if !empty($cache_page)}
            {assign var = page_cache_options value = $this->Setting->getConfigCacheView($page_code, {PAGE})}
        {/if}

        {$this->element('layout/page', [
            'structure' => $page_structure
        ], $page_cache_options)}
    {/if}

    {if $use_header_v2}
        {$this->element('layout/footer_v2')}
        {foreach from = $kept_footer_rows item = row}
            {$this->element('layout/row', ['row' => $row], [])}
        {/foreach}
        {$this->element('layout/action_bar')}
    {/if}



    {$this->element('layout/modal', [], $this->Setting->getConfigCacheView('modal', {LAYOUT}))}
    <input id="nh-data-init" type="hidden" value="{if !empty($data_init)}{htmlentities($data_init|@json_encode)}{/if}">



    {$this->element('schema/company', [], $this->Setting->getConfigCacheView('schema_company', {LAYOUT}))}
    {$this->element('schema/website', [], $this->Setting->getConfigCacheView('schema_website', {LAYOUT}))}

    {if !empty(PAGE_TYPE) && PAGE_TYPE != HOME}
        {$this->element('schema/breadcrumb')}
    {/if}

    {if !empty(PAGE_TYPE) && PAGE_TYPE == PRODUCT_DETAIL}
        {$this->element('schema/product_detail')}
    {/if}

    {if !empty(PAGE_TYPE) && PAGE_TYPE == ARTICLE_DETAIL}
        {$this->element('schema/article_detail')}
    {/if}
    

    {$this->element('layout/js', [], $this->Setting->getConfigCacheView('js', {LAYOUT}))}


    {if !empty($embed_code.bottom_body) && empty($embed_code.time_delay)}
        {$embed_code.bottom_body}
    {/if}


    {assign var = social value = []}
    {if !empty($data_init.social)}
        {assign var = social value = $data_init.social}
    {/if}

    {* Facebook sign-in is disabled; do not load its login SDK. *}
    
    
    
    {$this->element('../Notification/bell')}

</body>
</html>
