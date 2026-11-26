<main class="mpr" id="course-price-root" data-price-page data-list-id="{$list.id|default:0}" data-list-slug="{$list.slug|escape}" data-course-type="{$list.course_type|escape}" data-quantity-mode="{if $list.course_type=='quiz'}months{elseif $list.course_type=='document'}credits{else}courses{/if}" data-catalog-url="{$list.catalog_url|escape}" data-from="{$from}" data-recommended-year="{$recommended_year|escape}" data-member="{if !empty($member.id)}1{else}0{/if}">
  <div class="mpr-shell">
    {if $packages}
    {$video_board = in_array($list.course_type, ['knowledge', 'exam_solution'])}
    {if $video_board && $from}
      {$subject = $this->Product->getDetailProduct($from, null, ['get_attributes' => true])}
      {if $subject}
        {$subject_instructors = $this->Article->courseInstructorNames($subject.attributes.thongtingiangvien.value|default:'')}
        {$subject_lessons = $subject.attributes.soluongbaihoc.value|default:''|strip_tags|trim}
        {if $subject_lessons == ''}
          {$courses_by_id = array_column($courses, null, 'id')}
          {if !empty($courses_by_id[$from].lessons)}{$subject_lessons = "{$courses_by_id[$from].lessons} bài học"}{/if}
        {/if}
        <section class="mpr-subject" aria-labelledby="mpr-subject-title">
          <header>
            <p class="mpr-eyebrow">Môn bạn đang xem</p>
            <h2 id="mpr-subject-title">{$subject.name|escape}</h2>
          </header>
          <dl>
            {if $subject_instructors}<div><dt>Giảng viên</dt><dd>{implode(', ', $subject_instructors)|escape}</dd></div>{/if}
            {if $subject_lessons != ''}<div><dt>Số buổi</dt><dd>{$subject_lessons|escape}</dd></div>{/if}
            <div><dt>Nội dung</dt><dd>{if $list.course_type == 'exam_solution'}Video chữa đề theo môn{else}Video bài giảng theo lộ trình{/if}</dd></div>
          </dl>
        </section>
      {/if}
    {/if}
    <section aria-labelledby="mpr-packages-title">
      <div class="mpr-section-head"><h1 id="mpr-packages-title">Chọn gói phù hợp.</h1><span>{if $list.course_type=='quiz'}Chọn thời hạn cho một môn{elseif $list.course_type=='document'}Lượt dùng chung cho mọi tài liệu{else}{$courses|count} môn để bạn lựa chọn{/if}</span></div>
      {if $video_board}
        <section class="mpr-course-guarantee" aria-labelledby="mpr-guarantee-title">
          <h3 id="mpr-guarantee-title">Cam kết học tập</h3>
          {$this->element('course_price/guarantees')}
        </section>
      {/if}
      {if !empty($voucher_available)}<p><button class="mv-choice-button" type="button" data-price-voucher>Nhập mã ưu đãi</button></p>{/if}
      <div class="mpr-packages">
      {foreach $packages as $p}
        <article class="mpr-package{if $p.recommended} is-recommended{/if}" data-package="{$p.id}" data-count="{$p.course_count}" data-amount="{$p.amount}" data-name="{$p.name|escape}">
          <div class="mpr-package-heading"><h2>{if $list.course_type=='quiz'}{if $p.duration_months==12}1 <span>năm</span>{else}{$p.duration_months} <span>tháng</span>{/if}{elseif $list.course_type=='document'}{$p.credit_count} <span>lượt tải</span>{elseif $p.bonus_count}{$p.course_count-$p.bonus_count}<span class="mpr-bonus"> + {$p.bonus_count}</span> <span>môn học</span>{else}{$p.course_count} <span>môn học</span>{/if}</h2>{if $p.recommended}<span class="mpr-tag">{if $p.bonus_count}Ưu đãi tốt nhất{else}Tiết kiệm nhất{/if}</span>{/if}</div>
          {capture name=mpr_plan_price}
            <div class="mpr-price-panel"><span class="mpr-price-label">{if $list.course_type=='document'}Trọn gói{elseif $list.course_type=='quiz'}Giá gói{else}Học phí{/if}</span>
            {$show_price_term = isset($p.unit_amount)}
            <div class="mpr-price{if $show_price_term} mpr-price--with-term{/if}">
              <span>{$p.amount|number_format:0:',':'.'}{if $show_price_term} {/if}<small>đ</small></span>
              {if $show_price_term}<span class="mpr-price-term">/ {if $list.course_type=='quiz'}{$p.duration_months} tháng{else}{$p.credit_count} lượt{/if}</span>{/if}
            </div>
            <div class="mpr-price-meta">{if $p.saving}<del>{$p.price|number_format:0:',':'.'}đ</del><span class="mpr-saving">Tiết kiệm {$p.saving}%</span>{else}<span>{if $list.course_type=='document'}Thanh toán một lần{elseif $list.course_type=='quiz'}Trọn thời hạn đã chọn{else}Học phí trọn gói{/if}</span>{/if}</div>
            {if $show_price_term}
              <p class="mpr-unit-price">
                Bình quân: <strong>{$p.unit_amount|number_format:0:',':'.'} đ / {if $list.course_type=='quiz'}tháng{else}lượt{/if}</strong>
              </p>
            {/if}
            </div>
          {/capture}
          {if $list.course_type=='document'}{$smarty.capture.mpr_plan_price}{/if}
          {if $video_board && $p.duration_months}<p class="mpr-duration">Quyền học {$p.duration_months} tháng</p>{/if}
          <ul class="mpr-benefits">
            {foreach $p.lines as $line}<li><span class="mpr-benefit-check" aria-hidden="true">✓</span><span>{$line|escape}</span></li>{/foreach}
            {if $video_board}
              <li><span class="mpr-benefit-check" aria-hidden="true">✓</span><span><strong>Tặng {$p.course_count*$gift_downloads} lượt tải</strong>{if $p.course_count > 1} · {$gift_downloads} lượt mỗi môn{else} tài liệu đúng môn{/if}</span></li>
              <li><span class="mpr-benefit-check" aria-hidden="true">✓</span><span><strong>Tặng {$gift_quiz_months} tháng Đề thi</strong> {if $p.course_count > 1}cho mỗi môn{else}cùng môn{/if}</span></li>
            {/if}
          </ul>
          {if $list.course_type!='document'}<div class="mpr-choice">
            <div class="mpr-choice-head"><strong data-plan-count aria-live="polite">Đã chọn {if $from}1{else}0{/if}/{$p.course_count} môn</strong><button type="button" data-edit-plan="{$p.id}" aria-haspopup="dialog">Chọn thêm <span aria-hidden="true">+</span></button></div>
            <div class="mpr-plan-courses" data-plan-courses></div>
          </div>
            {$smarty.capture.mpr_plan_price}
          {/if}
          <button class="mpr-btn mpr-plan-button" type="button" data-register-plan="{$p.id}" aria-pressed="false" {if $list.course_type!='document' && $p.course_count>count($courses)}disabled{/if}>Chọn mua gói <span aria-hidden="true">→</span></button>
        </article>
      {/foreach}
      </div>
    </section>
    <p class="mpr-under-note">{if $list.course_type=='quiz'}Thời hạn bắt đầu khi admin xác nhận thanh toán. Mỗi gói áp dụng cho một môn.{elseif $list.course_type=='document'}Admin duyệt để cộng lượt. Mỗi tệp tải thành công dùng 1 lượt; số dư không hết hạn.{else}Chọn gói và các môn bạn cần để tiếp tục thanh toán.{/if}</p>
    <p class="mpr-error" data-price-error role="alert"></p>
    <script type="application/json" data-price-catalog>{$catalog_json}</script>

    <dialog class="mpr-dialog" data-course-dialog aria-labelledby="mpr-dialog-title">
      <div class="mpr-dialog-head"><div><p class="mpr-eyebrow">MÔN HỌC CỦA BẠN</p><h2 id="mpr-dialog-title">Chọn môn học</h2><p data-suggestion-caption></p></div><button class="mpr-dialog-close" type="button" data-close-dialog aria-label="Đóng cửa sổ chọn môn">×</button></div>
      <div class="mpr-dialog-tools"><label class="mpr-search"><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="10" cy="10" r="7"/><path d="m15 15 6 6"/></svg><input type="search" data-course-search placeholder="Tìm môn học…" aria-label="Tìm môn học"></label><select data-year-filter aria-label="Năm học gợi ý"><option value="">Mọi năm học</option><option value="1">Sinh viên năm 1</option><option value="2">Sinh viên năm 2</option><option value="3">Sinh viên năm 3</option><option value="4">Sinh viên năm 4</option><option value="5">Sinh viên năm 5</option><option value="6">Sinh viên năm 6</option><option value="graduate">Sau tốt nghiệp</option></select></div>
      <div class="mpr-dialog-body"><div class="mpr-dialog-section"><h3 data-course-list-title>Đề xuất cho bạn</h3><a data-browse-all href="{$list.catalog_url|escape}">Xem tất cả →</a></div><div class="mpr-courses" data-dialog-courses></div><p class="mpr-empty" data-empty hidden>Chưa có môn phù hợp. Hãy thử tìm kiếm hoặc xem tất cả.</p></div>
      <div class="mpr-dialog-foot"><div><strong data-dialog-count aria-live="polite"></strong><p class="mpr-error" data-dialog-error role="status"></p></div><button class="mpr-btn" type="button" data-apply-courses>Lưu lựa chọn <span aria-hidden="true">→</span></button></div>
    </dialog>

    {else}<p class="mpr-empty">Bảng giá đang được cập nhật. <a href="/khoa-hoc">Khám phá khóa học →</a></p>{/if}
  </div>
</main>
