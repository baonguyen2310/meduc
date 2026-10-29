<!DOCTYPE html>
<html lang="vi" csrf-token="{$this->getRequest()->getAttribute('csrfToken')|escape}">
<head>
  <meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
  <title>{$title_for_layout|escape}</title>
  <script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/theme-init.js?v=20261014"></script>
  <link href="/templates/{CODE_TEMPLATE}/assets/css/fonts.css" rel="stylesheet">
  {$this->element('layout/css')}
  <link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/header.css?v=20261029-account-menu-2" rel="stylesheet">
  <script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/header.js?v=20261018-1" defer></script>
  <link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/footer.css?v=20261021-1" rel="stylesheet">
  <link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/auth.css?v=20261021-7" rel="stylesheet">
  <link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/course-price-cart.css?v=20261022-8" rel="stylesheet">
  <link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/course-pricing.css?v=20261022-6" rel="stylesheet">
  {assign website_info value=$this->Setting->getWebsiteInfo()}
  <link rel="icon" href="{$this->Utilities->getWebsiteImageUrl($website_info.favicon)|escape}">
  <script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/auth.js?v=20261029-avatar" defer></script>
  <script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/course-price-cart.js?v=20261028-preview" defer></script>
  <script src="/bang-bao-gia/lien-ket.js" defer></script>
  <script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/course-pricing.js?v=20261022-7" defer></script>
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
