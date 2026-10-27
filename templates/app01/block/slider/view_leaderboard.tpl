{strip}
{* Bảng xếp hạng (trang /class-rank, block "bxhrank"): hai tab.
   - Bảng xếp hạng: theo một khóa hoặc mọi khóa, trong tuần / tháng / từ trước đến nay. Ba người đầu đứng trên bục có vương
     miện vàng, bạc, đồng; bên dưới là toàn bộ thứ hạng, dòng của người xem được tô sáng.
   - Chỉ số tiến bộ: của học viên đang đăng nhập, theo từng khóa đã học: số đề, điểm, thời gian, biểu đồ điểm qua các lần làm,
     tỉ lệ đúng theo chương. Sổ tay câu sai nằm trong lịch sử từng bài tập.
   Địa chỉ: ?khoa=id khóa, ?ky=tuan|thang, ?tab=tien-bo; địa chỉ cũ ?class-room-id= mở khóa của lớp đó.
   Dữ liệu: LeaderboardHelper (từ lịch sử làm bài). Giao diện: assets/meduc-v2/leaderboard.css và leaderboard.js. *}
{$selection = $this->Leaderboard->getSelection()}
{$member = $this->Member->getMemberInfo()}
{$member_id = 0}
{if !empty($member.id)}{$member_id = $member.id}{/if}
{$courses = $this->Leaderboard->getCourses()}
{$course = []}
{foreach from = $courses item = item}{if $item.id == $selection.product_id}{$course = $item}{/if}{/foreach}
{$board = $this->Leaderboard->getBoard($selection.product_id, $selection.period, $member_id)}
{$periods = ['tat-ca' => 'Tất cả', 'thang' => 'Tháng này', 'tuan' => 'Tuần này']}

{* Tab 2: khóa của học viên, mặc định là khóa đang chọn nếu học viên có khóa đó, không thì khóa học gần nhất *}
{$member_courses = $this->Leaderboard->getMemberCourses($member_id)}
{$progress_course = []}
{foreach from = $member_courses item = item}{if $item.id == $selection.product_id}{$progress_course = $item}{/if}{/foreach}
{if empty($progress_course) && !empty($member_courses)}{$progress_course = $member_courses[0]}{/if}
{$progress = null}
{if !empty($progress_course)}{$progress = $this->Leaderboard->getProgress($member_id, $progress_course.id)}{/if}

{capture name = mlb_crown}<svg class="mlb-crown" viewBox="0 0 64 48" aria-hidden="true"><path d="M6 40 2 12l16 12L32 4l14 20 16-12-4 28z" /><rect x="6" y="41" width="52" height="6" rx="3" /><circle cx="2.5" cy="11" r="3" /><circle cx="32" cy="4" r="3.5" /><circle cx="61.5" cy="11" r="3" /></svg>{/capture}

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/leaderboard.css?v=20261016-5" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/leaderboard.js?v=20261016" defer></script>

<section class="mlb" data-mlb>
    <div class="mlb-shell">
        <header class="mlb-head">
            <p class="mlb-kicker">MedUC / Cộng đồng học tập</p>
            <h1 class="mlb-title">Mỗi ngày một chút.<br><em>Tiến xa hơn.</em></h1>
            <p class="mlb-lead">Tôn vinh những học viên luyện đề đều đặn, và giúp bạn thấy mình đã tiến bộ đến đâu sau mỗi buổi học.</p>
        </header>

        <nav class="mlb-tabs" role="tablist" aria-label="Bảng xếp hạng">
            <a role="tab" id="mlb-tab-bxh" href="{$this->Leaderboard->link(['tab' => 'bxh'])}" aria-controls="mlb-panel-bxh" aria-selected="{if $selection.tab == 'bxh'}true{else}false{/if}" data-mlb-tab="bxh">
                <span class="mlb-tab-number">01</span>Bảng xếp hạng
            </a>
            <a role="tab" id="mlb-tab-tien-bo" href="{$this->Leaderboard->link(['tab' => 'tien-bo'])}" aria-controls="mlb-panel-tien-bo" aria-selected="{if $selection.tab == 'tien-bo'}true{else}false{/if}" data-mlb-tab="tien-bo">
                <span class="mlb-tab-number">02</span>Chỉ số tiến bộ của bạn
            </a>
        </nav>

        {* ---------------- Tab 1: bảng xếp hạng ---------------- *}
        <div class="mlb-panel" id="mlb-panel-bxh" role="tabpanel" aria-labelledby="mlb-tab-bxh" data-mlb-panel="bxh" {if $selection.tab != 'bxh'}hidden{/if}>
            <div class="mlb-filters">
                <label class="mlb-field">
                    <span>Khoá học</span>
                    <select data-mlb-go>
                        <option value="{$this->Leaderboard->link(['khoa' => 0])}">Mọi khoá học</option>
                        {foreach from = $courses item = item}
                            <option value="{$this->Leaderboard->link(['khoa' => $item.id])}" {if $item.id == $selection.product_id}selected{/if}>{$item.name|escape}</option>
                        {/foreach}
                    </select>
                </label>
                <div class="mlb-field">
                    <span>Kỳ xếp hạng</span>
                    <div class="mlb-segment">
                        {foreach from = $periods key = period_code item = period_label}
                            <a href="{$this->Leaderboard->link(['ky' => $period_code])}" {if $period_code == $selection.period}class="is-active" aria-current="true"{/if}>{$period_label}</a>
                        {/foreach}
                    </div>
                </div>
            </div>

            {if empty($board.rows)}
                <div class="mlb-empty">
                    <h2>Chưa có ai trên bảng {if $selection.period == 'tuan'}tuần này{elseif $selection.period == 'thang'}tháng này{else}này{/if}.</h2>
                    <p>Làm bài tập trong khoá học để có tên trên bảng xếp hạng.</p>
                    {if $selection.period != 'tat-ca'}<a class="mlb-btn mlb-btn--ghost" href="{$this->Leaderboard->link(['ky' => 'tat-ca'])}">Xem bảng từ trước đến nay</a>{/if}
                </div>
            {else}
                {* Bục: hạng 2, hạng 1, hạng 3 *}
                <ol class="mlb-podium" aria-label="Ba học viên đứng đầu">
                    {foreach from = [1, 0, 2] item = place}
                        {if empty($board.rows[$place])}{continue}{/if}
                        {$row = $board.rows[$place]}
                        <li class="mlb-podium-item mlb-place-{$row.rank}{if $row.me} is-me{/if}">
                            <span class="mlb-podium-rank" aria-hidden="true">{$row.rank|string_format:'%02d'}</span>
                            <p class="mlb-podium-label">Hạng {$row.rank|string_format:'%02d'}</p>
                            <div class="mlb-avatar-wrap">
                                {$smarty.capture.mlb_crown}
                                <span class="mlb-avatar">{$row.initials|escape}</span>
                            </div>
                            <strong class="mlb-podium-name">{$row.name|escape}{if $row.me} · Bạn{/if}</strong>
                            <p class="mlb-podium-points"><b>{$row.points|number_format:0:',':'.'}</b> điểm</p>
                            <p class="mlb-podium-meta">{$row.accuracy}% câu đúng · {$row.days} ngày luyện</p>
                        </li>
                    {/foreach}
                </ol>

                <div class="mlb-grid">
                    <div class="mlb-card mlb-ranks">
                        <div class="mlb-card-head">
                            <h2>Toàn bộ thứ hạng</h2>
                            <span>{if !empty($course)}{$course.name|escape}{else}Mọi khoá học{/if} · {$board.range} · {$board.total|number_format:0:',':'.'} học viên</span>
                        </div>
                        <table class="mlb-table">
                            <thead>
                                <tr>
                                    <th scope="col">Hạng</th>
                                    <th scope="col">Học viên</th>
                                    <th scope="col" class="mlb-col-days">Ngày luyện</th>
                                    <th scope="col" class="mlb-col-accuracy">Đúng</th>
                                    <th scope="col" class="mlb-col-points">Điểm</th>
                                </tr>
                            </thead>
                            <tbody>
                                {foreach from = $board.rows item = row}
                                    <tr class="{if $row.rank <= 3}mlb-place-{$row.rank}{/if}{if $row.me} is-me{/if}">
                                        <td class="mlb-col-rank">{if $row.rank <= 3}{$smarty.capture.mlb_crown}{/if}<span>{$row.rank|string_format:'%02d'}</span></td>
                                        <td><div class="mlb-learner"><span class="mlb-avatar mlb-avatar--small">{$row.initials|escape}</span><span><strong>{$row.name|escape}</strong>{if $row.me}<small>Bạn · cứ thế tiến lên!</small>{else}<small>{$row.quizzes} đề đã làm</small>{/if}</span></div></td>
                                        <td class="mlb-col-days">{$row.days} ngày</td>
                                        <td class="mlb-col-accuracy">{$row.accuracy}%</td>
                                        <td class="mlb-col-points">{$row.points|number_format:0:',':'.'}</td>
                                    </tr>
                                {/foreach}
                                {if !empty($board.me) && $board.me.rank > count($board.rows)}
                                    <tr class="mlb-gap" aria-hidden="true"><td colspan="5">···</td></tr>
                                    <tr class="is-me">
                                        <td class="mlb-col-rank"><span>{$board.me.rank}</span></td>
                                        <td><div class="mlb-learner"><span class="mlb-avatar mlb-avatar--small">{$board.me.initials|escape}</span><span><strong>{$board.me.name|escape}</strong><small>Bạn · cứ thế tiến lên!</small></span></div></td>
                                        <td class="mlb-col-days">{$board.me.days} ngày</td>
                                        <td class="mlb-col-accuracy">{$board.me.accuracy}%</td>
                                        <td class="mlb-col-points">{$board.me.points|number_format:0:',':'.'}</td>
                                    </tr>
                                {/if}
                            </tbody>
                        </table>
                    </div>

                    <aside class="mlb-side">
                        <div class="mlb-card mlb-journey">
                            <p class="mlb-card-kicker">Hành trình của bạn</p>
                            {if !$member_id}
                                <h3>Đăng nhập để thấy thứ hạng của bạn.</h3>
                                <p>Kết quả làm bài của bạn được lưu lại và tính vào bảng xếp hạng.</p>
                                <a class="mlb-btn" href="/member/login">Đăng nhập</a>
                            {else}
                                {if !empty($board.me)}
                                    <h3>Hạng {$board.me.rank} · {$board.me.points|number_format:0:',':'.'} điểm.</h3>
                                    <p>{if $board.me.rank == 1}Bạn đang dẫn đầu, giữ vững phong độ nhé.{elseif $board.me.rank <= 10}Bạn đang trong top 10. Thêm vài đề nữa là lên hạng.{else}Mỗi đề làm thêm là một bước tiến. Hãy tiếp tục giữ nhịp.{/if}</p>
                                {else}
                                    <h3>Bạn chưa có tên trên bảng này.</h3>
                                    <p>Làm một bài tập trong khoá học để bắt đầu tích điểm.</p>
                                {/if}
                                <ol class="mlb-week" aria-label="7 ngày gần nhất">
                                    {foreach from = $this->Leaderboard->getWeek($member_id) item = day}
                                        <li class="{if $day.done}is-done{/if}{if $day.today} is-today{/if}" title="{$day.date}{if $day.done}: có làm bài{/if}">
                                            <span class="mlb-week-dot">{if $day.done}<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5" /></svg>{/if}</span>
                                            <span>{$day.label}</span>
                                        </li>
                                    {/foreach}
                                </ol>
                                <a class="mlb-btn" href="{if !empty($progress_course.url)}{$progress_course.url}?bai=1{else}/khoa-hoc{/if}">Luyện đề tiếp</a>
                            {/if}
                        </div>
                        <div class="mlb-note">
                            <strong>Điểm được tính thế nào?</strong>
                            <p>Mỗi câu đúng là 1 điểm, tính ở lần làm tốt nhất của mỗi đề, nên làm lại để ôn bài không làm mất điểm. Bằng điểm thì ai có tỉ lệ đúng cao hơn đứng trước. "Ngày luyện" là số ngày có nộp bài trong kỳ.</p>
                        </div>
                    </aside>
                </div>
            {/if}
        </div>

        {* ---------------- Tab 2: chỉ số tiến bộ ---------------- *}
        <div class="mlb-panel" id="mlb-panel-tien-bo" role="tabpanel" aria-labelledby="mlb-tab-tien-bo" data-mlb-panel="tien-bo" {if $selection.tab != 'tien-bo'}hidden{/if}>
            {if !$member_id}
                <div class="mlb-empty">
                    <h2>Đăng nhập để xem chỉ số tiến bộ của bạn.</h2>
                    <p>Điểm qua từng lần làm bài, điểm mạnh theo chương và những câu cần ôn lại đều có ở đây.</p>
                    <a class="mlb-btn" href="/member/login">Đăng nhập</a>
                </div>
            {elseif empty($member_courses)}
                <div class="mlb-empty">
                    <h2>Bạn chưa làm bài tập nào.</h2>
                    <p>Vào một khoá học, mở tab "Bài tập" của buổi học để bắt đầu. Kết quả sẽ hiện ở đây.</p>
                    <a class="mlb-btn" href="/khoa-hoc">Xem các khoá học</a>
                </div>
            {else}
                <nav class="mlb-courses" aria-label="Khoá học của bạn">
                    {foreach from = $member_courses item = item}
                        <a href="{$this->Leaderboard->link(['khoa' => $item.id, 'tab' => 'tien-bo'])}" {if $item.id == $progress_course.id}class="is-active" aria-current="page"{/if}>{$item.name|escape}</a>
                    {/foreach}
                </nav>

                <div class="mlb-progress-head">
                    <div>
                        <p class="mlb-kicker">Theo dõi hành trình học</p>
                        <h2 class="mlb-title mlb-title--small">Chỉ số <em>tiến bộ.</em></h2>
                        <p class="mlb-lead">{$progress_course.name|escape}</p>
                    </div>
                    <a class="mlb-link" href="{$progress_course.url}">Vào khoá học <span aria-hidden="true">→</span></a>
                </div>

                {if empty($progress)}
                    <div class="mlb-empty">
                        <h2>Bạn chưa làm bài tập nào của khoá này.</h2>
                        <p>Mở tab "Bài tập" ở một buổi học để bắt đầu.</p>
                        <a class="mlb-btn" href="{$progress_course.url}?bai=1">Vào khoá học</a>
                    </div>
                {else}
                    <div class="mlb-stats">
                        <div class="mlb-stat">
                            <p>01 / Đề đã làm</p>
                            <strong>{$progress.quizzes_done}{if $progress.quizzes_total > 0}<small>/ {$progress.quizzes_total}</small>{/if}</strong>
                            <span>{if $progress.quizzes_total > 0}{min(100, round($progress.quizzes_done / $progress.quizzes_total * 100))}% số đề của khoá{else}{$progress.attempts} lần nộp bài{/if}</span>
                        </div>
                        <div class="mlb-stat">
                            <p>02 / Điểm trung bình</p>
                            <strong>{$progress.average}<small>/ 100</small></strong>
                            <span>Cao nhất {$progress.best} điểm</span>
                        </div>
                        <div class="mlb-stat">
                            <p>03 / Thời gian làm bài</p>
                            <strong>{if $progress.minutes >= 60}{($progress.minutes / 60)|string_format:'%.1f'|replace:'.':','}<small>giờ</small>{else}{$progress.minutes}<small>phút</small>{/if}</strong>
                            <span>{$progress.attempts} lần nộp bài</span>
                        </div>
                        <div class="mlb-stat">
                            <p>04 / Câu cần ôn lại</p>
                            <strong>{$progress.mistakes_total}<small>câu</small></strong>
                            <span>Ở lần làm gần nhất mỗi đề</span>
                        </div>
                    </div>

                    <div class="mlb-charts">
                        <div class="mlb-card">
                            <p class="mlb-card-kicker">01 / Điểm qua từng lần làm</p>
                            <h3>Đi lên mỗi buổi học.</h3>
                            <div class="mlb-trend" data-mlb-trend="{htmlentities(json_encode($progress.trend, 256))}"></div>
                            <p class="mlb-card-foot">{count($progress.trend)} lần nộp gần nhất, thang 100 điểm</p>
                        </div>
                        <div class="mlb-card">
                            <p class="mlb-card-kicker">02 / Bản đồ năng lực</p>
                            <h3>Hiểu rõ điểm mạnh.</h3>
                            <div class="mlb-radar" data-mlb-radar="{htmlentities(json_encode($progress.chapters, 256))}"></div>
                            <ul class="mlb-bars">
                                {foreach from = $progress.chapters item = chapter}
                                    <li>
                                        <span class="mlb-bar-name">{$chapter.name|escape}</span>
                                        <span class="mlb-bar" aria-hidden="true"><span style="width: {$chapter.score}%"></span></span>
                                        <b>{$chapter.score}%</b>
                                    </li>
                                {/foreach}
                            </ul>
                        </div>
                    </div>

                {/if}
            {/if}
        </div>
    </div>
</section>
{/strip}
