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
    <link href="{if !empty($website_info.favicon)}{CDN_URL}{$website_info.favicon}{else}/favicon.ico{/if}" rel="icon" type="image/x-icon"/>
    {$this->element('layout/css', [], $this->Setting->getConfigCacheView('css', {LAYOUT}))}

    {if !empty(PAGE_TYPE) && PAGE_TYPE == 'home'}
        <script src="/hero-light/assets/original-home-theme-init.js"></script>
        <link href="/hero-light/assets/original-home.css?v=20261007-header-nav" rel="stylesheet" />
        <link href="/hero-light/assets/featured-courses.css?v=20261007-badge-top" rel="stylesheet" />
        <link href="/hero-light/assets/faculty.css?v=20261007-faculty-portrait3" rel="stylesheet" />
        <link href="/hero-light/assets/home-books.css?v=20261007-home-books" rel="stylesheet" />
        <link href="/hero-light/assets/home-feedback.css?v=20261007-home-feedback" rel="stylesheet" />
        <link href="/hero-light/assets/home-testimonials.css?v=20261007-home-testimonials" rel="stylesheet" />
        <link href="/hero-light/assets/home-blog.css?v=20261007-home-blog" rel="stylesheet" />
        <link href="/hero-light/assets/home-consult.css?v=20261007-home-consult-cta" rel="stylesheet" />
        <link href="/hero-light/assets/home-community.css?v=20261007-home-counters" rel="stylesheet" />
        <link href="/hero-light/assets/home-learning-system.css?v=20261007-home-learning-system" rel="stylesheet" />
        <link href="/hero-light/assets/home-impact.css?v=20261007-home-counters" rel="stylesheet" />
        <link href="/hero-light/assets/home-footer.css?v=20261007-home-footer" rel="stylesheet" />
        <script src="/hero-light/assets/original-home.js?v=20261007-header-nav" defer></script>
        <script src="/hero-light/assets/featured-courses.js?v=20261007-featured-polish" defer></script>
        <script src="/hero-light/assets/faculty.js?v=20261007-faculty-crop" defer></script>
        <script src="/hero-light/assets/home-books.js?v=20261007-home-books" defer></script>
        <script src="/hero-light/assets/home-feedback.js?v=20261007-home-feedback" defer></script>
        <script src="/hero-light/assets/home-testimonials.js?v=20261007-home-testimonials" defer></script>
        <script src="/hero-light/assets/home-blog.js?v=20261007-home-testimonials" defer></script>
        <script src="/hero-light/assets/home-consult.js?v=20261007-home-consult" defer></script>
        <script src="/hero-light/assets/home-community.js?v=20261007-home-counters" defer></script>
        <script src="/hero-light/assets/home-learning-system.js?v=20261007-home-learning-system" defer></script>
        <script src="/hero-light/assets/home-impact.js?v=20261007-home-counters" defer></script>
        <script src="/templates/app01/assets/eduvibe/js/vendor/odometer.js?v=20261007-counter-roll" defer></script>
        <script src="/hero-light/assets/home-counters.js?v=20261007-home-counters" defer></script>
        <script src="/hero-light/assets/home-footer.js?v=20261007-home-footer" defer></script>
    {/if}

    {if !empty(PAGE_TYPE) && PAGE_TYPE == PRODUCT_DETAIL}
        <link href="/hero-light/assets/course-classroom.css?v=20261007-classroom3" rel="stylesheet" />
        <script src="/hero-light/assets/course-classroom.js?v=20261007-classroom3" defer></script>
    {/if}


    {assign var = embed_code value = []}
    {if !empty($data_init.embed_code)}
        {assign var = embed_code value = $data_init.embed_code}
    {/if}

    {if !empty($embed_code.head) && empty($embed_code.time_delay)}
        {$embed_code.head}
    {/if}
    
    {*<link href="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.6.347/pdf_viewer.min.css" rel="stylesheet" type="text/css" />*}
</head>

<body class="{if !empty(DEVICE)}is-mobile{/if} {if !empty(PAGE_TYPE == 'home')}home meduc-home-v2{/if}">
    {if !empty($embed_code.top_body) && empty($embed_code.time_delay)}
        {$embed_code.top_body}
    {/if}

    {if !empty(PAGE_TYPE) && PAGE_TYPE == 'home'}
        {$this->element('home/header_hero')}
    {/if}

    {if !empty($page_code) && !empty($structure)}
        {assign var = page_cache_options value = []}
        {if !empty($cache_page)}
            {assign var = page_cache_options value = $this->Setting->getConfigCacheView($page_code, {PAGE})}
        {/if}

        {$this->element('layout/page', [
            'structure' => $structure
        ], $page_cache_options)}
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

    {if !empty($social.facebook_load_sdk) && empty($social.facebook_sdk_delay)}
        {$this->element('layout/facebook_sdk', ['social' => $social])}
    {/if}
    
    {if !empty($social.google_load_sdk) && empty($social.google_sdk_delay)}
        {$this->element('layout/google_sdk', ['social' => $social])}
    {/if}
    
    
    {$this->element('../Notification/bell')}

</body>
</html>
