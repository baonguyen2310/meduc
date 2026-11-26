{strip}
{$member_courses = $this->loadHelper('MemberCourses')}
{$dashboard = $member_courses->dashboard()}
{$active = $dashboard.active_kind}
{$group = $dashboard.groups[$active]}
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/course-catalog.css?v=20261124" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/member-courses.css?v=20261125-purchase-gifts" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/member-courses.js?v=20261124" defer></script>

<main class="mcl member-courses" id="member-courses" data-signed-in="{if $dashboard.signed_in}1{else}0{/if}">
    <section class="member-courses-intro" aria-labelledby="member-courses-title">
        <div class="mcl-shell member-courses-hero">
            <h1 id="member-courses-title">Khoá học <span>đang tham gia</span></h1>
            <aside class="member-courses-credits" aria-labelledby="member-courses-credits-title">
                <span class="member-courses-download-icon" aria-hidden="true"><i class="fa-solid fa-download"></i></span>
                <div>
                    <h2 id="member-courses-credits-title">Lượt tải tài liệu còn lại</h2>
                    {if $dashboard.signed_in && $dashboard.credits !== null}
                        <strong>{$dashboard.credits|number_format:0:',':'.'}</strong>
                        {if $dashboard.credit_balances.subjects}
                            <ul class="member-course-credit-breakdown">
                                <li>{$dashboard.credit_balances.shared} lượt dùng chung</li>
                                {foreach $dashboard.credit_balances.subjects as $balance}
                                    <li>{$balance.remaining} lượt · {$balance.name|escape}</li>
                                {/foreach}
                            </ul>
                        {/if}
                    {elseif $dashboard.signed_in}
                        <p>Chưa tải được số lượt.</p>
                    {else}
                        <p>Đăng nhập để xem số lượt.</p>
                    {/if}
                    <a href="/tai-lieu-hoc-tap">Xem tài liệu <span aria-hidden="true">→</span></a>
                </div>
            </aside>
        </div>
    </section>

    <nav class="member-courses-nav" aria-label="Phân loại khoá học">
        <div class="mcl-shell member-courses-tabs">
            {foreach from=$dashboard.groups item=entry key=kind}
                <a id="member-courses-type-{$kind}" href="/khoa-hoc-da-dang-ky?loai={$kind}"{if $kind === $active} aria-current="page"{/if}>
                    {$entry.label|escape}
                    {if $dashboard.signed_in && !$dashboard.courses_unavailable}<span class="member-courses-tab-count">{count($entry.courses)}</span>{/if}
                </a>
            {/foreach}
        </div>
    </nav>

    <section class="mcl-shell member-courses-content" aria-labelledby="member-courses-type-{$active}">
        {if $dashboard.pending_gifts || $dashboard.gift_notice}
            <section class="member-course-gifts" id="qua-mua-hang" aria-labelledby="member-course-gifts-title">
                <h2 id="member-course-gifts-title">Quà Đề thi</h2>
                {if $dashboard.gift_notice}
                    <p class="member-course-gift-notice{if !$dashboard.gift_notice.ok} is-error{/if}" role="status">{$dashboard.gift_notice.message|escape}</p>
                {/if}
                {foreach $dashboard.pending_gifts as $gift}
                    <div class="member-course-gift">
                        <div><strong>{$gift.months} tháng Đề thi{if $gift.subject_name} · {$gift.subject_name|escape}{/if}</strong>
                            <p>Đơn {$gift.order_code|escape}</p></div>
                        {if $gift.choices}
                            <form action="/uu-dai/nhan-qua-mua-hang" method="post">
                                <input type="hidden" name="_csrfToken" value="{$this->getRequest()->getAttribute('csrfToken')|escape}">
                                <input type="hidden" name="gift_id" value="{$gift.id}">
                                {if count($gift.choices) > 1}
                                    <label for="gift-quiz-{$gift.id}">Môn nhận quà</label>
                                    <select id="gift-quiz-{$gift.id}" name="quiz_id" required>
                                        <option value="">Chọn môn</option>
                                        {foreach $gift.choices as $quiz}<option value="{$quiz.id}">{$quiz.name|escape}</option>{/foreach}
                                    </select>
                                {else}
                                    <input type="hidden" name="quiz_id" value="{$gift.choices[0].id}">
                                    {if !$gift.subject_name}<span>{$gift.choices[0].name|escape}</span>{/if}
                                {/if}
                                <button class="mcl-register" type="submit">Nhận quà</button>
                            </form>
                        {elseif $gift.shop}
                            <p>Đang chờ MedUC mở môn Đề thi tặng kèm.</p>
                        {else}
                            <p>Bộ đề môn này đang được cập nhật.</p>
                        {/if}
                    </div>
                {/foreach}
            </section>
        {/if}
        {if !$dashboard.signed_in}
            <div class="member-courses-empty">
                <h2>Đăng nhập để xem khoá học của bạn</h2>
                <a class="mcl-register" href="/member/login" data-ma-open="login" aria-haspopup="dialog" aria-controls="login-modal">Đăng nhập</a>
                <p role="status" data-member-courses-login-status hidden></p>
            </div>
        {elseif $dashboard.courses_unavailable}
            <div class="member-courses-empty">
                <h2>Chưa tải được danh sách khoá học</h2>
                <a class="mcl-register" href="/khoa-hoc-da-dang-ky?loai={$active}">Thử lại</a>
            </div>
        {elseif empty($group.courses)}
            <div class="member-courses-empty">
                <h2>Bạn chưa có khoá nào trong nhóm này</h2>
                <a class="mcl-register" href="{$group.catalogue|escape}">Xem danh sách khoá</a>
            </div>
        {else}
            <div class="member-courses-grid">
                {foreach from=$group.courses item=course}
                    {$url = $this->Utilities->checkInternalUrl($course.url)}
                    <article class="member-course-card">
                        <div class="member-course-cover{if empty($course.image)} member-course-cover-empty{/if}" aria-hidden="true">
                            {if !empty($course.image)}
                                <img src="{CDN_URL}{$this->Utilities->getThumbs($course.image, 500)|escape}" alt="" loading="lazy" decoding="async">
                            {elseif $active === 'quiz'}
                                <i class="fa-solid fa-clipboard-list"></i>
                            {else}
                                <i class="fa-solid fa-circle-play"></i>
                            {/if}
                        </div>
                        <div class="member-course-copy">
                            <h3>{$course.name|escape}</h3>
                                {if $active === 'quiz' && $course.expiry}<p class="member-course-expiry">Hạn sử dụng đến {$course.expiry|escape}</p>{/if}
                            <div class="member-course-actions">
                                <a class="mcl-register member-course-open" href="{$url|escape}" aria-label="{$group.action|escape} {$course.name|escape}">{$group.action|escape} <span aria-hidden="true">→</span></a>
                                <a class="member-course-rank" href="/class-rank?khoa={$course.id}" aria-label="Bảng xếp hạng {$course.name|escape}">BXH</a>
                            </div>
                        </div>
                    </article>
                {/foreach}
            </div>
        {/if}
    </section>
</main>
{/strip}
