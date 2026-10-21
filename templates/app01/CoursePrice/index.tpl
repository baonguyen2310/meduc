<main class="mpr" id="course-price-root" data-price-page data-list-id="{$list.id|default:0}" data-from="{$from}">
  <div class="mpr-shell">
    <div class="mpr-breadcrumb"><a href="/">Trang chủ</a><span>/</span><span>Bảng báo giá</span></div>
    {if count($lists)>1}<nav class="mpr-switch" aria-label="Chọn bảng báo giá">{foreach $lists as $l}<a href="/bang-bao-gia/{$l.slug|escape}" {if $list.id==$l.id}aria-current="page"{/if}>{$l.name|escape}</a>{/foreach}</nav>{/if}
    <header class="mpr-hero">
      <p class="mpr-eyebrow">MEDUC / BẢNG BÁO GIÁ</p>
      <h1>{if $list}{$list.name|escape}{else}Học theo cách của bạn.{/if}</h1>
      <p class="mpr-lead">{if $list}{$list.description|escape}{else}Các gói học sẽ sớm được cập nhật.{/if}</p>
    </header>
    {if $packages}
    <section aria-labelledby="mpr-packages-title">
      <div class="mpr-section-head"><h2 id="mpr-packages-title">Chọn gói phù hợp.</h2><span>{$courses|count} môn để bạn lựa chọn</span></div>
      <div class="mpr-packages">
      {foreach $packages as $p}
        <article class="mpr-package{if $p.recommended} is-recommended{/if}">
          <div class="mpr-package-top"><span>{$p.name|escape}</span>{if $p.recommended}<span class="mpr-tag">Đề xuất</span>{/if}</div>
          <h3>{$p.course_count} <span>môn học</span></h3>
          <div class="mpr-price">{$p.amount|number_format:0:',':'.'}<small>đ</small></div>
          <div class="mpr-price-meta">{if $p.saving}<del>{$p.price|number_format:0:',':'.'}đ</del><span>Giảm {$p.saving}%</span>{else}<span>Học phí trọn gói</span>{/if}</div>
          <ul>{foreach $p.lines as $line}<li>{$line|escape}</li>{/foreach}</ul>
          <button class="mpr-btn{if !$p.recommended} mpr-btn--outline{/if}" type="button" data-select-package="{$p.id}" {if $p.course_count>count($courses)}disabled{/if}>Chọn gói <span aria-hidden="true">→</span></button>
        </article>
      {/foreach}
      </div>
    </section>
    <section class="mpr-picker" id="chon-mon" aria-labelledby="mpr-picker-title">
      <div class="mpr-section-head"><div><p class="mpr-eyebrow">LỘ TRÌNH CỦA RIÊNG BẠN</p><h2 id="mpr-picker-title">Bạn muốn học những môn nào?</h2></div></div>
      <form data-price-form>
        <input type="hidden" name="token" value="{$token|escape}">
        <fieldset class="mpr-tier"><legend class="mhi-sr-only">Gói học</legend>{foreach $packages as $p}<label><input type="radio" name="package_id" value="{$p.id}" data-count="{$p.course_count}" data-amount="{$p.amount}" data-name="{$p.name|escape}" {if $p.course_count>count($courses)}disabled{/if}><span>{$p.name|escape}</span></label>{/foreach}</fieldset>
        <div class="mpr-picker-tools"><label class="mpr-search"><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="10" cy="10" r="7"/><path d="m15 15 6 6"/></svg><input type="search" data-course-search placeholder="Tìm môn bạn muốn học…" aria-label="Tìm môn học"></label><span data-selection-count aria-live="polite"></span></div>
        <div class="mpr-selected" data-selected aria-label="Các môn đã chọn"></div>
        <div class="mpr-contact"><label for="mpr-phone">Số điện thoại liên hệ</label><input id="mpr-phone" name="phone" type="tel" autocomplete="tel" value="{$customer.phone|default:''|escape}" placeholder="Nhập số điện thoại của bạn" required><p>Bạn sẽ kiểm tra đơn và chọn phương thức thanh toán ở bước tiếp theo.</p></div>
        <div class="mpr-courses">{foreach $courses as $i=>$c}<label class="mpr-course" data-name="{$c.name|escape}"><input type="checkbox" name="course_ids[]" value="{$c.id}"><span class="mpr-course-check" aria-hidden="true">✓</span><span>{$c.name|escape}</span></label>{/foreach}</div>
        <p class="mpr-empty" data-empty hidden>Không tìm thấy môn phù hợp.</p>

        <p class="mpr-error" data-price-error role="alert"></p>
        <div class="mpr-checkout"><div><span data-summary-name>Chọn gói học</span><strong data-summary-price></strong><small data-summary-count></small></div><button class="mpr-btn" type="submit" data-checkout>Tiếp tục đăng ký <span aria-hidden="true">→</span></button></div>
      </form>
    </section>
    {else}<p class="mpr-empty">Bảng giá đang được cập nhật. <a href="/khoa-hoc">Khám phá khóa học →</a></p>{/if}
  </div>
</main>
