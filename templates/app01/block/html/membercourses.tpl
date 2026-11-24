{strip}
{$member_courses = $this->loadHelper('MemberCourses')}
{$dashboard = $member_courses->dashboard()}
{$active = $dashboard.active_kind}
{$group = $dashboard.groups[$active]}
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/course-catalog.css?v=20261124" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/member-courses.css?v=20261124" rel="stylesheet">
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
