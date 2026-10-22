<main class="mpr" id="course-price-root" data-price-page data-list-id="{$list.id|default:0}" data-list-slug="{$list.slug|escape}" data-course-type="{$list.course_type|escape}" data-from="{$from}" data-recommended-year="{$recommended_year|escape}" data-member="{if !empty($member.id)}1{else}0{/if}">
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
        <article class="mpr-package{if $p.recommended} is-recommended{/if}" data-package="{$p.id}" data-count="{$p.course_count}" data-amount="{$p.amount}" data-name="{$p.name|escape}">
          <div class="mpr-package-top"><span>{$p.name|escape}</span>{if $p.recommended}<span class="mpr-tag">Đề xuất</span>{/if}</div>
          <h3>{$p.course_count} <span>môn học</span></h3>
          <div class="mpr-price">{$p.amount|number_format:0:',':'.'}<small>đ</small></div>
          <div class="mpr-price-meta">{if $p.saving}<del>{$p.price|number_format:0:',':'.'}đ</del><span>Giảm {$p.saving}%</span>{else}<span>Học phí trọn gói</span>{/if}</div>
          <ul>{foreach $p.lines as $line}<li>{$line|escape}</li>{/foreach}</ul>
          <div class="mpr-choice">
            <div class="mpr-choice-head"><strong data-plan-count aria-live="polite">Đã chọn {if $from}1{else}0{/if}/{$p.course_count} môn</strong><button type="button" data-edit-plan="{$p.id}" aria-haspopup="dialog">Chọn thêm <span aria-hidden="true">+</span></button></div>
            <div class="mpr-plan-courses" data-plan-courses></div>
          </div>
          <button class="mpr-btn{if !$p.recommended} mpr-btn--outline{/if}" type="button" data-register-plan="{$p.id}" {if $p.course_count>count($courses)}disabled{/if}>Đăng ký gói <span aria-hidden="true">→</span></button>
        </article>
      {/foreach}
      </div>
    </section>
    <p class="mpr-under-note">Chọn gói, thêm môn bạn cần và kiểm tra thông tin trước khi thanh toán.</p>
    <input type="hidden" data-price-token value="{$token|escape}">
    <script type="application/json" data-price-catalog>{$catalog_json}</script>

    <dialog class="mpr-dialog" data-course-dialog aria-labelledby="mpr-dialog-title">
      <div class="mpr-dialog-head"><div><p class="mpr-eyebrow">MÔN HỌC CỦA BẠN</p><h2 id="mpr-dialog-title">Chọn môn học</h2><p data-suggestion-caption></p></div><button class="mpr-dialog-close" type="button" data-close-dialog aria-label="Đóng cửa sổ chọn môn">×</button></div>
      <div class="mpr-dialog-tools"><label class="mpr-search"><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="10" cy="10" r="7"/><path d="m15 15 6 6"/></svg><input type="search" data-course-search placeholder="Tìm môn học…" aria-label="Tìm môn học"></label><select data-year-filter aria-label="Năm học gợi ý"><option value="">Mọi năm học</option><option value="1">Sinh viên năm 1</option><option value="2">Sinh viên năm 2</option><option value="3">Sinh viên năm 3</option><option value="4">Sinh viên năm 4</option><option value="5">Sinh viên năm 5</option><option value="6">Sinh viên năm 6</option><option value="graduate">Sau tốt nghiệp</option></select></div>
      <div class="mpr-dialog-body"><div class="mpr-dialog-section"><h3 data-course-list-title>Đề xuất cho bạn</h3><a data-browse-all href="{if $list.course_type=='exam_prep'}/khoa-luyen-thi{else}/khoa-hoc{/if}">Xem tất cả →</a></div><div class="mpr-courses" data-dialog-courses></div><p class="mpr-empty" data-empty hidden>Chưa có môn phù hợp. Hãy thử tìm kiếm hoặc xem tất cả.</p></div>
      <div class="mpr-dialog-foot"><div><strong data-dialog-count aria-live="polite"></strong><p class="mpr-error" data-dialog-error role="status"></p></div><button class="mpr-btn" type="button" data-apply-courses>Lưu lựa chọn <span aria-hidden="true">→</span></button></div>
    </dialog>

    <dialog class="mpr-dialog mpr-confirm-dialog" data-checkout-dialog aria-labelledby="mpr-confirm-title">
      <form data-price-form>
        <div class="mpr-dialog-head"><div><p class="mpr-eyebrow">ĐĂNG KÝ HỌC</p><h2 id="mpr-confirm-title">Kiểm tra lựa chọn.</h2></div><button class="mpr-dialog-close" type="button" data-close-dialog aria-label="Đóng cửa sổ đăng ký">×</button></div>
        <div class="mpr-dialog-body"><div class="mpr-confirm-total"><span data-checkout-name></span><strong data-checkout-price></strong></div><ul class="mpr-confirm-courses" data-checkout-courses></ul><div class="mpr-contact"><label for="mpr-phone">Số điện thoại liên hệ</label><input id="mpr-phone" name="phone" type="tel" autocomplete="tel" value="{$customer.phone|default:''|escape}" placeholder="Nhập số điện thoại của bạn" required><p>Bạn sẽ chọn phương thức thanh toán ở bước tiếp theo.</p></div><p class="mpr-error" data-price-error role="alert"></p></div>
        <div class="mpr-dialog-foot"><button class="mpr-text-button" type="button" data-back-to-courses>Đổi môn</button><button class="mpr-btn" type="submit" data-checkout>Tiếp tục thanh toán <span aria-hidden="true">→</span></button></div>
      </form>
    </dialog>
    {else}<p class="mpr-empty">Bảng giá đang được cập nhật. <a href="/khoa-hoc">Khám phá khóa học →</a></p>{/if}
  </div>
</main>
