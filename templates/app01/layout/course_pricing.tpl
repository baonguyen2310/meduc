<!DOCTYPE html>
<html lang="vi" csrf-token="{$this->getRequest()->getAttribute('csrfToken')|escape}">
<head>
  <meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
  <title>{$title_for_layout|escape}</title>
  <script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/theme-init.js?v=20261014"></script>
  <link href="/templates/{CODE_TEMPLATE}/assets/css/fonts.css" rel="stylesheet">
  {$this->element('layout/css')}
  <link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/header.css?v=20261112-logo-compact" rel="stylesheet">
  <script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/header.js?v=20261030-scroll-nav" defer></script>
  <link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/footer.css?v=20261112-logo-new" rel="stylesheet">
  <link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/auth.css?v=20261110-google-profile" rel="stylesheet">
  <link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/course-price-cart.css?v=20261022-8" rel="stylesheet">
  <link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/course-pricing.css?v=20261110-commerce-access" rel="stylesheet">
  {assign website_info value=$this->Setting->getWebsiteInfo()}
  <link rel="icon" href="{$this->Utilities->getWebsiteImageUrl($website_info.favicon)|escape}{if strpos($website_info.favicon, '/templates/app01/assets/meduc-v2/brand/meduc-') === 0}?v=20261112-logo-new{/if}">
  <script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/auth.js?v=20261110-google-profile" defer></script>
  <script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/checkout-entry.js?v=20261110-commerce-access" defer></script>
  <script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/course-price-cart.js?v=20261110-commerce-access" defer></script>
  <script src="/bang-bao-gia/lien-ket.js" defer></script>
  <script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/course-pricing.js?v=20261110-commerce-access" defer></script>
</head>
<body class="meduc-header-v2 mpr-body">
{$this->element('layout/header_v2')}
{$this->fetch('content')}
{$this->element('layout/footer_v2')}
{$this->element('layout/modal')}
<input id="nh-data-init" type="hidden" value="{htmlentities($data_init|@json_encode)}">
{$this->element('layout/js')}
</body>
</html>
