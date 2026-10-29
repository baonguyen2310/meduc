{strip}
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/theme-usage.js?v=20261028-1" defer></script>
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/course-history.css?v=20261028-no-price" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/course-history.js?v=20261028-no-price" defer></script>
{* Site header ported from the main branch. The logo and website name come from Admin > Settings > Website information. *}
{assign var = website_info value = $this->Setting->getWebsiteInfo()}
{$header_member = $this->Member->getMemberInfo()}
{$header_course_cart = $this->Cart->getCartInfo()}
{$meduc_brand = !empty($website_info.company_logo) && strpos($website_info.company_logo, '/templates/app01/assets/meduc-v2/brand/meduc-') === 0}
{assign var = website_name value = "{if !empty($website_info.website_name)}{$website_info.website_name}{else}MedUC{/if}"}

{* Each link list is declared once and rendered in both the desktop bars and the mobile menu. *}
{$nav_courses = [
  ['url' => '/khoa-hoc', 'label' => 'Khoá ôn kiến thức', 'icon' => 'book'],
  ['url' => '/khoa-hoc?loai=exam_solution', 'label' => 'Khoá chữa đề', 'icon' => 'pulse']
]}
{$nav_secondary = [
  ['url' => '/gioi-thieu', 'label' => 'Giới thiệu'],
  ['url' => '/doi-ngu-giang-vien', 'label' => 'Giảng viên'],
  ['url' => '/phuong-phap-hoc', 'label' => 'Phương pháp học'],
  ['url' => '/phan-hoi-hoc-vien', 'label' => 'Phản hồi'],
  ['url' => '/lo-trinh-hoc', 'label' => 'Lộ trình học'],
  ['url' => '/class-rank', 'label' => 'Xếp hạng']
]}

{* Product categories are shared with Admin and the year-filtered catalogue. *}
{$nav_exam_items = []}
{$nav_book_items = []}
{$nav_exam_categories = $this->Category->getListCategories({PRODUCT}, {LANGUAGE}, [{FILTER} => ['parent_id' => 125], {SORT} => [{FIELD} => 'position', {SORT} => 'asc']])}
{$nav_book_categories = $this->Category->getListCategories({PRODUCT}, {LANGUAGE}, [{FILTER} => ['parent_id' => 79], {SORT} => [{FIELD} => 'position', {SORT} => 'asc']])}
{foreach from = $nav_exam_categories item = category}{$nav_exam_items[] = ['url' => $this->Utilities->checkInternalUrl($category.url), 'label' => $category.name, 'icon' => 'book']}{/foreach}
{foreach from = $nav_book_categories item = category}{if count($nav_book_items) >= 4}{break}{/if}{$nav_book_items[] = ['url' => $this->Utilities->checkInternalUrl($category.url), 'label' => $category.name, 'icon' => 'book']}{/foreach}
{$nav_main = [
  ['id' => 'browse', 'label' => 'Khoá học', 'url' => '/khoa-hoc', 'items' => $nav_courses],
  ['id' => 'practice', 'label' => 'Trắc nghiệm', 'url' => '/trac-nghiem', 'all' => 'Xem tất cả môn trắc nghiệm', 'items' => $nav_exam_items],
  ['id' => 'books', 'label' => 'Sách', 'url' => '/sach-y-khoa', 'all' => 'Xem tất cả sách', 'items' => $nav_book_items],
  ['id' => 'blog', 'label' => 'Blog', 'url' => '/blog'],
  ['id' => 'documents', 'label' => 'Tài liệu', 'url' => '/tai-lieu-hoc-tap']
]}

<div class="mhi mhi-header-wrap" id="meduc-header">
  <svg class="mhi-icon-sprites" aria-hidden="true" xmlns="http://www.w3.org/2000/svg">
    <symbol id="mhi-icon-arrow" viewBox="0 0 24 24"><path d="M4 12h16m-6-6 6 6-6 6" /></symbol>
    <symbol id="mhi-icon-book" viewBox="0 0 24 24"><path d="M12 5v16M12 5C8 3 5 3 2 4v15c3-1 6-1 10 2 4-3 7-3 10-2V4c-3-1-6-1-10 1Z" /></symbol>
    <symbol id="mhi-icon-gift" viewBox="0 0 24 24"><path d="M4 10v11h16V10M2 6h20v4H2zM12 6v15M12 6H7.5A2.5 2.5 0 1 1 10 3.5L12 6Zm0 0h4.5A2.5 2.5 0 1 0 14 3.5L12 6Z"/></symbol>
    <symbol id="mhi-icon-journal" viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M7 7h10M7 11h10M7 15h6"/></symbol>
    <symbol id="mhi-icon-document" viewBox="0 0 24 24"><path d="M14 2H5v20h14V7l-5-5Zm0 0v5h5M8 12h8M8 16h6"/></symbol>
    <symbol id="mhi-icon-pulse" viewBox="0 0 24 24"><path d="M2 12h5l3-8 4 16 3-8h5" /></symbol>
    <symbol id="mhi-icon-users" viewBox="0 0 24 24"><circle cx="9" cy="7" r="3"/><path d="M2 21v-3a7 7 0 0 1 14 0v3M17 4a3 3 0 0 1 0 6m2 4a5 5 0 0 1 3 5v2" /></symbol>
    <symbol id="mhi-icon-chevron" viewBox="0 0 24 24"><path d="m6 9 6 6 6-6" /></symbol>
    <symbol id="mhi-icon-search" viewBox="0 0 24 24"><circle cx="10.5" cy="10.5" r="7"/><path d="m16 16 5 5"/></symbol>
    <symbol id="mhi-icon-user" viewBox="0 0 24 24"><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/></symbol>
    <symbol id="mhi-icon-sun" viewBox="0 0 24 24"><circle cx="12" cy="12" r="4"/><path d="M12 2v2m0 16v2M4.93 4.93l1.42 1.42m11.3 11.3 1.42 1.42M2 12h2m16 0h2M4.93 19.07l1.42-1.42m11.3-11.3 1.42-1.42"/></symbol>
    <symbol id="mhi-icon-moon" viewBox="0 0 24 24"><path d="M19.1 16.4A8.15 8.15 0 0 1 7.6 4.9a8.35 8.35 0 1 0 11.5 11.5Z" fill="currentColor" stroke="none"/><path d="M18.3 3.3v3.2m-1.6-1.6h3.2"/></symbol>
  </svg>
  <a class="mhi-skip" href="#mhi-content-start">Đến nội dung chính</a>
  <header class="mhi-header">
    <div class="mhi-network">
      <nav class="mhi-shell mhi-network-links" aria-label="Điều hướng MedUC">
        {foreach from = $nav_secondary item = link}
          <a href="{$link.url|escape}">{$link.label|escape}</a>
        {/foreach}
      </nav>
    </div>
    <div class="mhi-shell mhi-header-main">
      <a class="mhi-brand{if $meduc_brand} mhi-brand--meduc{/if}" href="/" aria-label="{$website_name|escape} — Trang chủ">
        {if !empty($website_info.company_logo)}
          {if $meduc_brand}
            <img class="mhi-brand-wordmark mhi-brand-wordmark--light" src="{$this->Utilities->getWebsiteImageUrl($website_info.company_logo)|escape}" alt="{$website_name|escape}" decoding="async" />
            <img class="mhi-brand-wordmark mhi-brand-wordmark--dark" src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/brand/meduc-khai-mo-dark.svg" alt="" aria-hidden="true" decoding="async" />
            <img class="mhi-brand-mark" src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/brand/meduc-khai-mo-mark.svg" alt="" aria-hidden="true" decoding="async" width="64" height="54" />
          {else}
            <img src="{$this->Utilities->getWebsiteImageUrl($website_info.company_logo)|escape}" alt="{$website_name|escape}" decoding="async" />
          {/if}
        {else}
          <span class="mhi-brand-text">{$website_name|escape}</span>
        {/if}
      </a>
      <form class="mhi-search" id="mhi-search-form" action="/tim-kiem" method="get" role="search" autocomplete="off">
        <button type="submit" aria-label="Tìm kiếm"><svg class="mhi-icon" aria-hidden="true"><use href="#mhi-icon-search" /></svg></button>
        <label class="mhi-sr-only" for="mhi-search-input">Tìm khóa học, sách, đề thi</label>
        <input id="mhi-search-input" name="keyword" type="search" nh-auto-suggest="{PRODUCT}" placeholder="Hôm nay bạn muốn học gì?" value="{$this->Utilities->getParamsByKey('keyword')|escape}" />
      </form>
      <button class="mhi-icon-button mhi-search-toggle" id="mhi-search-toggle" type="button" aria-label="Tìm kiếm" aria-expanded="false" aria-controls="mhi-search-form"><svg class="mhi-icon" aria-hidden="true"><use href="#mhi-icon-search" /></svg></button>
      <nav class="mhi-utility" aria-label="Tài khoản và tiện ích">
        {foreach from = $nav_main item = group}
          {if isset($group.items)}
          <div class="mhi-browse-wrap" data-mhi-dropdown>
            <button class="mhi-browse-button{if $group.id == 'browse'} mhi-course-button{/if}" id="mhi-{$group.id}-button" type="button" aria-expanded="false" aria-controls="mhi-{$group.id}-menu">
              {$group.label|escape}<svg class="mhi-icon mhi-chevron" aria-hidden="true"><use href="#mhi-icon-chevron" /></svg>
            </button>
            <nav class="mhi-browse-menu" id="mhi-{$group.id}-menu" aria-label="Danh mục {$group.label|escape}" hidden>
              {foreach from = $group.items item = link}
                <a href="{$link.url|escape}"><svg class="mhi-icon" aria-hidden="true"><use href="#mhi-icon-{$link.icon|escape}" /></svg>{$link.label|escape}<svg class="mhi-icon mhi-arrow" aria-hidden="true"><use href="#mhi-icon-arrow" /></svg></a>
              {/foreach}
              {if !empty($group.all)}<a class="mhi-browse-all" href="{$group.url|escape}">{$group.all|escape}<svg class="mhi-icon mhi-arrow" aria-hidden="true"><use href="#mhi-icon-arrow" /></svg></a>{/if}
            </nav>
          </div>
          {else}
            <a class="mhi-browse-button mhi-main-link" href="{$group.url|escape}">{$group.label|escape}</a>
          {/if}
        {/foreach}
        <a class="mhi-cart" data-course-cart-open data-course-cart-legacy="{$header_course_cart.total_quantity|default:0}" href="/bang-bao-gia" title="Giỏ hàng khóa học" aria-label="Giỏ hàng khóa học" aria-haspopup="dialog">
          <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M5.5 8h13l-1 12.5h-11L5.5 8Z"/><path d="M9 10.5V7a3 3 0 0 1 6 0v3.5"/></svg>
          <span data-course-cart-count class="mhi-cart-count">{$header_course_cart.total_quantity|default:0}</span>
        </a>
        <a class="mhi-cart mhi-cart-book" nh-mini-cart-book href="/dat-hang" title="Giỏ hàng sách và thiết bị" aria-label="Giỏ hàng sách và thiết bị">
          <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M2.5 4h2.3l2.4 11h10.6l2-8H6"/><circle cx="9" cy="19.5" r="1.3"/><circle cx="17" cy="19.5" r="1.3"/></svg>
          <span nh-mini-cart-book-quantity class="mhi-cart-count">0</span>
        </a>
        <button class="mhi-theme-toggle" data-mhi-theme-toggle type="button" aria-label="Chuyển sang chế độ sáng" aria-pressed="true" title="Chuyển sang chế độ sáng">
          <svg class="mhi-icon mhi-sun" aria-hidden="true"><use href="#mhi-icon-sun" /></svg>
          <svg class="mhi-icon mhi-moon" aria-hidden="true"><use href="#mhi-icon-moon" /></svg>
        </button>
      </nav>
      <div class="mhi-member" nh-mini-member{if empty($header_member)} hidden{/if}>
        {if !empty($header_member)}{$this->element('../Member/mini')}{/if}
      </div>
      <button class="mhi-header-cta" type="button" data-ma-open="login" aria-haspopup="dialog" aria-controls="login-modal"{if !empty($header_member)} hidden{/if}>Bắt đầu học</button>
      <button class="mhi-icon-button mhi-menu-toggle" id="mhi-menu-toggle" type="button" aria-label="Mở menu" aria-expanded="false" aria-controls="mhi-drawer">
        <svg class="mhi-icon" aria-hidden="true"><path d="M4 7h16M4 12h16M4 17h16" /></svg>
      </button>
    </div>
  </header>

  <div class="mhi-drawer" id="mhi-drawer" role="dialog" aria-modal="true" aria-label="Menu MedUC" hidden>
    <div class="mhi-drawer-backdrop" data-mhi-drawer-close></div>
    <nav class="mhi-drawer-panel" aria-label="Menu MedUC">
      <div class="mhi-drawer-head">
        <span class="mhi-drawer-title">Menu</span>
        <button class="mhi-icon-button" type="button" data-mhi-drawer-close aria-label="Đóng menu"><svg class="mhi-icon" aria-hidden="true"><path d="M6 6l12 12M18 6 6 18" /></svg></button>
      </div>
      {foreach from = $nav_main item = group}
        {if isset($group.items)}
        <details class="mhi-drawer-group" data-mhi-main-group="{$group.id}">
          <summary class="mhi-drawer-link">{$group.label|escape}<svg class="mhi-icon" aria-hidden="true"><use href="#mhi-icon-chevron" /></svg></summary>
          {foreach from = $group.items item = link}<a class="mhi-drawer-sublink" href="{$link.url|escape}">{$link.label|escape}</a>{/foreach}
          {if !empty($group.all)}<a class="mhi-drawer-sublink mhi-drawer-all" href="{$group.url|escape}">{$group.all|escape} →</a>{/if}
        </details>
        {else}
          <a class="mhi-drawer-link" href="{$group.url|escape}">{$group.label|escape}</a>
        {/if}
      {/foreach}
      <p class="mhi-drawer-label">Về MedUC</p>
      {foreach from = $nav_secondary item = link}
        <a class="mhi-drawer-link" href="{$link.url|escape}">{$link.label|escape}</a>
      {/foreach}
      <a class="mhi-drawer-link" href="/dat-hang">Giỏ sách &amp; thiết bị</a>

      <div class="mhi-drawer-foot">
        <button class="mhi-drawer-theme" data-mhi-theme-toggle type="button" aria-label="Chuyển sang chế độ sáng" aria-pressed="true">
          <svg class="mhi-icon mhi-sun" aria-hidden="true"><use href="#mhi-icon-sun" /></svg>
          <svg class="mhi-icon mhi-moon" aria-hidden="true"><use href="#mhi-icon-moon" /></svg>
          <span>Đổi giao diện sáng/tối</span>
        </button>
        <a class="mhi-header-cta" data-ma-member-link href="/khoa-hoc-da-dang-ky"{if empty($header_member)} hidden{/if}>Khoá học của tôi</a>
        <button class="mhi-header-cta" type="button" data-ma-open="login" aria-haspopup="dialog" aria-controls="login-modal"{if !empty($header_member)} hidden{/if}>Bắt đầu học</button>
      </div>
    </nav>
  </div>
</div>
<span id="mhi-content-start" tabindex="-1"></span>
{/strip}
