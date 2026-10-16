{strip}
{$dashboard = $this->MemberDashboard->overview()}
{$first_course = $dashboard.courses[0]|default:[]}
{$initial = mb_strtoupper(mb_substr($member.full_name|default:'M', 0, 1))}
{$order_status = $this->Order->getListStatusOrder()}
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/member-dashboard.css?v=20261016-1" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/member-dashboard.js?v=20261016-1" defer></script>
<main class="mdb" id="member-dashboard">
    <svg class="mdb-sprites" aria-hidden="true" xmlns="http://www.w3.org/2000/svg">
        <symbol id="mdb-home" viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/></symbol>
        <symbol id="mdb-book" viewBox="0 0 24 24"><path d="M12 5v16M12 5C8 3 5 3 2 4v15c3-1 6-1 10 2 4-3 7-3 10-2V4c-3-1-6-1-10 1Z"/></symbol>
        <symbol id="mdb-chart" viewBox="0 0 24 24"><path d="M4 3v17h17M8 15l4-5 4 2 5-7"/></symbol>
        <symbol id="mdb-clock" viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></symbol>
        <symbol id="mdb-user" viewBox="0 0 24 24"><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/></symbol>
        <symbol id="mdb-bag" viewBox="0 0 24 24"><path d="M5 8h14l-1 13H6L5 8Zm4 0V6a3 3 0 0 1 6 0v2"/></symbol>
        <symbol id="mdb-arrow" viewBox="0 0 24 24"><path d="M4 12h16m-6-6 6 6-6 6"/></symbol>
        <symbol id="mdb-out" viewBox="0 0 24 24"><path d="M10 4H4v16h6m-1-8h12m-5-5 5 5-5 5"/></symbol>
        <symbol id="mdb-lock" viewBox="0 0 24 24"><rect x="5" y="10" width="14" height="11" rx="2"/><path d="M8 10V7a4 4 0 0 1 8 0v3m-4 4v3"/></symbol>
    </svg>
    <div class="mdb-shell">
        <aside class="mdb-sidebar" aria-label="Không gian học tập của bạn">
            <div class="mdb-identity">
                <div class="mdb-avatar">{if !empty($member.avatar)}<img src="{CDN_URL}{$this->Utilities->getThumbs($member.avatar, 150)|escape}" alt="Ảnh đại diện" />{else}{$initial|escape}{/if}</div>
                <div><strong>{$member.full_name|default:'Học viên MedUC'|escape}</strong><span>Học viên MedUC</span></div>
            </div>
            <p class="mdb-nav-label">KHÔNG GIAN CỦA BẠN</p>
            <nav class="mdb-nav" aria-label="Điều hướng tài khoản">
                <a href="#mdb-overview" data-mdb-nav aria-current="location"><svg aria-hidden="true" focusable="false" class="mdb-icon"><use href="#mdb-home"/></svg>Tổng quan</a>
                <a href="#mdb-courses" data-mdb-nav><svg aria-hidden="true" focusable="false" class="mdb-icon"><use href="#mdb-book"/></svg>Khóa học của tôi<span class="mdb-nav-count">{$dashboard.stats.courses}</span></a>
                <a href="#mdb-history" data-mdb-nav><svg aria-hidden="true" focusable="false" class="mdb-icon"><use href="#mdb-clock"/></svg>Bài làm gần đây</a>
                <a href="/class-rank?tab=tien-bo"><svg aria-hidden="true" focusable="false" class="mdb-icon"><use href="#mdb-chart"/></svg>Tiến bộ &amp; xếp hạng</a>
                <a href="#mdb-orders" data-mdb-nav><svg aria-hidden="true" focusable="false" class="mdb-icon"><use href="#mdb-bag"/></svg>Đơn hàng</a>
                <a href="#mdb-profile" data-mdb-nav><svg aria-hidden="true" focusable="false" class="mdb-icon"><use href="#mdb-user"/></svg>Thông tin tài khoản</a>
            </nav>
            <div class="mdb-nav mdb-nav-account">
                <a href="/member/change-password"><svg aria-hidden="true" focusable="false" class="mdb-icon"><use href="#mdb-lock"/></svg>Đổi mật khẩu</a>
                {if !empty($member.is_partner_affiliate)}<a href="/member/aff/dashboard"><svg aria-hidden="true" focusable="false" class="mdb-icon"><use href="#mdb-chart"/></svg>Tiếp thị liên kết</a>{/if}
                <a href="/member/logout"><svg aria-hidden="true" focusable="false" class="mdb-icon"><use href="#mdb-out"/></svg>Đăng xuất</a>
            </div>
            <div class="mdb-sidebar-note"><span>MEDUC / LEARNING SYSTEM</span><p>Mỗi bài học hôm nay.<br>Một bước vững vàng ngày mai.</p><a href="/khoa-hoc">Khám phá khóa học <span aria-hidden="true">↗</span></a></div>
        </aside>
        <div class="mdb-main">
            <header class="mdb-welcome" id="mdb-overview" data-mdb-section>
                <div><p class="mdb-eyebrow">HÀNH TRÌNH HỌC Y CỦA BẠN</p><h1>Chào {$member.full_name|default:'bạn'|escape}.</h1><p>Học thêm một chút. Vững vàng hơn mỗi ngày.</p></div>
                <a class="mdb-button" href="{if !empty($first_course.url)}{$first_course.url|escape}{else}/khoa-hoc{/if}">{if !empty($first_course.url)}Vào khóa học{else}Khám phá khóa học{/if}<svg aria-hidden="true" focusable="false" class="mdb-icon"><use href="#mdb-arrow"/></svg></a>
            </header>
            <div class="mdb-stats" aria-label="Tổng quan học tập">
                <div><svg aria-hidden="true" focusable="false" class="mdb-icon"><use href="#mdb-book"/></svg><strong>{$dashboard.stats.courses}</strong><span>Khóa học đang tham gia</span></div>
                <div><svg aria-hidden="true" focusable="false" class="mdb-icon"><use href="#mdb-chart"/></svg><strong>{$dashboard.stats.quizzes}</strong><span>Bài tập đã luyện</span></div>
                <div><svg aria-hidden="true" focusable="false" class="mdb-icon"><use href="#mdb-clock"/></svg><strong>{$dashboard.stats.attempts}</strong><span>Lượt nộp bài</span></div>
                <div><svg aria-hidden="true" focusable="false" class="mdb-icon"><use href="#mdb-home"/></svg><strong>{if $dashboard.stats.accuracy !== null}{$dashboard.stats.accuracy}<small>%</small>{else}—{/if}</strong><span>Tỉ lệ câu trả lời đúng</span></div>
            </div>
            <div class="mdb-columns">
                <div class="mdb-primary">
                    <section class="mdb-section" id="mdb-courses" data-mdb-section aria-labelledby="mdb-courses-title">
                        <div class="mdb-section-head"><div><p class="mdb-eyebrow">HỌC CÙNG MEDUC</p><h2 id="mdb-courses-title">Khóa học của tôi<span class="mdb-count">{$dashboard.stats.courses}</span></h2></div><a class="mdb-text-link" href="/khoa-hoc">Khám phá thêm <span aria-hidden="true">↗</span></a></div>
                        {if !empty($dashboard.courses)}
                            <div class="mdb-course-list">
                                {foreach from=$dashboard.courses item=course key=course_index}
                                    <article class="mdb-course" {if $course_index >= 4}data-mdb-extra hidden{/if}>
                                        <a class="mdb-course-image" href="{if !empty($course.url)}{$course.url|escape}{else}/khoa-hoc{/if}" aria-label="{$course.name|escape}">{if !empty($course.image)}<img src="{CDN_URL}{$course.image|escape}" alt="" loading="lazy" decoding="async">{else}<svg aria-hidden="true" focusable="false" class="mdb-icon"><use href="#mdb-book"/></svg>{/if}</a>
                                        <div class="mdb-course-copy"><p class="mdb-eyebrow">{if $course.exam_prep}KHÓA LUYỆN THI{else}KHÓA HỌC MEDUC{/if}</p><h3><a href="{if !empty($course.url)}{$course.url|escape}{else}/khoa-hoc{/if}">{$course.name|escape}</a></h3><p class="mdb-course-meta">{$course.chapters} chương <span>·</span> {$course.lessons} bài học{if $course.expires_at > 0}<span>·</span> Hạn học: {$course.expires_at|date_format:'%d/%m/%Y'}{/if}</p>
                                            {if $course.quizzes > 0}<div class="mdb-course-progress"><span>Đã luyện {$course.done}/{$course.quizzes} đề</span><span>{$course.percent}%</span></div><div class="mdb-progress" role="progressbar" aria-label="Số đề đã luyện trong {$course.name|escape}" aria-valuenow="{$course.done}" aria-valuemin="0" aria-valuemax="{$course.quizzes}"><span style="width:{$course.percent}%"></span></div>{else}<p class="mdb-course-note">Học theo lộ trình của khóa học.</p>{/if}
                                        </div>
                                        <a class="mdb-course-action" href="{if !empty($course.url)}{$course.url|escape}{else}/khoa-hoc{/if}">Vào học <svg aria-hidden="true" focusable="false" class="mdb-icon"><use href="#mdb-arrow"/></svg></a>
                                    </article>
                                {/foreach}
                            </div>
                            {if count($dashboard.courses) > 4}<button class="mdb-show-more" type="button" data-mdb-more aria-expanded="false">Xem thêm {count($dashboard.courses)-4} khóa học <span aria-hidden="true">↓</span></button>{/if}
                        {else}
                            <div class="mdb-empty"><svg aria-hidden="true" focusable="false" class="mdb-icon"><use href="#mdb-book"/></svg><h3>Hành trình của bạn bắt đầu từ đây.</h3><p>Bạn chưa có khóa học được cấp quyền. Khám phá lộ trình và chọn môn phù hợp với mình.</p><a class="mdb-button" href="/khoa-hoc">Tìm khóa học <svg aria-hidden="true" focusable="false" class="mdb-icon"><use href="#mdb-arrow"/></svg></a></div>
                        {/if}
                    </section>
                    <section class="mdb-section" id="mdb-history" data-mdb-section aria-labelledby="mdb-history-title">
                        <div class="mdb-section-head"><div><p class="mdb-eyebrow">NHÌN LẠI ĐỂ TIẾN BỘ</p><h2 id="mdb-history-title">Bài làm gần đây</h2></div><a class="mdb-text-link" href="/lich-su-lam-bai-tap">Tất cả bài làm <span aria-hidden="true">↗</span></a></div>
                        {if !empty($dashboard.recent)}
                            <div class="mdb-history-list">
                                {foreach from=$dashboard.recent item=attempt}<a class="mdb-attempt" href="/ket-qua-bai-tap?id={$attempt.id}"><span class="mdb-attempt-icon"><svg aria-hidden="true" focusable="false" class="mdb-icon"><use href="#mdb-chart"/></svg></span><div class="mdb-attempt-copy"><h3>{$attempt.quiz_name|default:$attempt.lesson_name|default:'Bài tập MedUC'|escape}</h3><p>{$attempt.course_name|default:'Bài luyện tập'|escape}</p><span>{$attempt.created|date_format:'%d/%m/%Y · %H:%M'} <span aria-hidden="true">·</span> {$attempt.answer_correct|default:0}/{$attempt.answer_total|default:0} câu đúng</span></div><span class="mdb-score">{if $attempt.score !== null}{$attempt.score}<small>%</small>{else}—{/if}</span><svg aria-hidden="true" focusable="false" class="mdb-icon mdb-attempt-arrow"><use href="#mdb-arrow"/></svg></a>{/foreach}
                            </div>
                        {else}
                            <div class="mdb-empty mdb-empty-compact"><svg aria-hidden="true" focusable="false" class="mdb-icon"><use href="#mdb-chart"/></svg><h3>Chưa có bài làm nào.</h3><p>Làm thử một đề để lưu kết quả và theo dõi sự tiến bộ của bạn.</p><a class="mdb-text-link" href="/khoa-luyen-thi">Khám phá luyện thi <span aria-hidden="true">→</span></a></div>
                        {/if}
                    </section>
                    <section class="mdb-section" id="mdb-orders" data-mdb-section aria-labelledby="mdb-orders-title">
                        <div class="mdb-section-head"><div><p class="mdb-eyebrow">TÀI KHOẢN MEDUC</p><h2 id="mdb-orders-title">Đơn hàng gần đây</h2></div><a class="mdb-text-link" href="/member/order">Tất cả đơn hàng <span aria-hidden="true">↗</span></a></div>
                        {if !empty($order)}<div class="mdb-orders">{foreach from=$order item=item}<a class="mdb-order" href="/member/order/detail/{$item.code|escape:'url'}"><div><strong>#{$item.code|escape}</strong><span>{$item.created|date_format:'%d/%m/%Y'}</span></div><span class="mdb-order-status">{$order_status[$item.status]|default:'Đang xử lý'|escape}</span><strong class="mdb-order-total">{$item.total|default:0|number_format:0:',':'.'}đ</strong><svg aria-hidden="true" focusable="false" class="mdb-icon"><use href="#mdb-arrow"/></svg></a>{/foreach}</div>{else}<p class="mdb-empty-line">Bạn chưa có đơn hàng nào trong hệ thống.</p>{/if}
                    </section>
                </div>
                <aside class="mdb-secondary" aria-label="Hoạt động và thông tin cá nhân">
                    <section class="mdb-week-card" aria-labelledby="mdb-week-title"><p class="mdb-eyebrow">GIỮ NHỊP HỌC MỖI NGÀY</p><h2 id="mdb-week-title">7 ngày vừa qua</h2><p><strong>{$dashboard.stats.days}/7</strong> ngày có bài nộp</p><div class="mdb-week">{foreach from=$dashboard.week item=day}<div class="{if $day.done}is-done{/if}{if $day.today} is-today{/if}"><span>{$day.label}</span><span class="mdb-week-dot" title="{$day.date}: {if $day.done}Có bài nộp{else}Chưa có bài nộp{/if}" aria-label="{$day.date}: {if $day.done}Có bài nộp{else}Chưa có bài nộp{/if}">{if $day.done}✓{else}·{/if}</span>{if $day.today}<small>Hôm nay</small>{/if}</div>{/foreach}</div><p class="mdb-week-note">Tổng thời gian luyện tập: {$dashboard.stats.minutes} phút, tính từ các bài đã nộp.</p></section>
                    <section class="mdb-profile-card" id="mdb-profile" data-mdb-section aria-labelledby="mdb-profile-title"><div class="mdb-section-head"><h2 id="mdb-profile-title">Hồ sơ của tôi</h2><svg aria-hidden="true" focusable="false" class="mdb-icon"><use href="#mdb-user"/></svg></div><dl><div><dt>Mã học viên</dt><dd>{$member.code|default:'Chưa cập nhật'|escape}</dd></div><div><dt>Họ và tên</dt><dd>{$member.full_name|default:'Chưa cập nhật'|escape}</dd></div><div><dt>Email</dt><dd>{$member.email|default:'Chưa cập nhật'|escape}</dd></div><div><dt>Số điện thoại</dt><dd>{$member.phone|default:'Chưa cập nhật'|escape}</dd></div>{if !empty($member.birthday)}<div><dt>Ngày sinh</dt><dd>{$member.birthday|escape}</dd></div>{/if}</dl><a class="mdb-outline-button" href="/member/profile">Chỉnh sửa thông tin <svg aria-hidden="true" focusable="false" class="mdb-icon"><use href="#mdb-arrow"/></svg></a></section>
                    <a class="mdb-practice-card" href="/khoa-luyen-thi"><p class="mdb-eyebrow">LUYỆN THI MEDUC</p><h2>Vững kiến thức.<br>Sẵn sàng mùa thi.</h2><p>Chọn môn học và bắt đầu với các đề làm thử miễn phí.</p><span>Luyện đề ngay <svg aria-hidden="true" focusable="false" class="mdb-icon"><use href="#mdb-arrow"/></svg></span></a>
                </aside>
            </div>
        </div>
    </div>
</main>
{/strip}
