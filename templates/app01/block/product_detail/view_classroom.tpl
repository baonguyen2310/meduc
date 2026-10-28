{strip}
{* Course information appears above the classroom with Giới thiệu / Tổng quan / Phản hồi tabs.
   Tổng quan displays only the course image attribute anhtongquan, selected in the product admin.
   The classroom keeps the course outline and lesson Video / Tài liệu / Bài tập / Giới thiệu tabs.
   Lessons and access come from Danh sách tiết học and MemberHelper::getCourseAccess.
   Quizzes use App\Lib\LessonQuizzes and classroom-quiz.js; locked questions are never sent to the page.
   Student feedback videos come from fbvideos; sign-up uses the existing cart.
   Block text keys: link_zalo, loi_moi, ghi_chu_bai_tap. *}
{assign var = product value = []}
{if !empty($data_block.data)}{assign var = product value = $data_block.data}{/if}
{assign var = text value = []}
{if !empty($data_extend.locale[{LANGUAGE}])}{assign var = text value = $data_extend.locale[{LANGUAGE}]}{/if}

{if !empty($product)}
{assign var = first_item value = []}
{if !empty($product.items[0])}{assign var = first_item value = $product.items[0]}{/if}

{* Who is looking: a student of the course has an old class room with their code, or an enrollment. *}
{assign var = member_info value = $this->Member->getMemberInfo()}
{assign var = code_member value = ''}
{if !empty($member_info.code)}{assign var = code_member value = $member_info.code}{/if}
{$course_access = $this->Member->getCourseAccess($product.id)}
{$licensed = !empty($course_access)}
{$class_room_id = ''}
{if !empty($course_access.class_room_id)}{$class_room_id = $course_access.class_room_id}{/if}

{* Sign-up: a course already in the cart goes straight to the order page. *}
{assign var = in_cart value = false}
{if !$licensed}
    {assign var = cart_info value = $this->Cart->getCartInfo()}
    {if !empty($cart_info.items)}
        {foreach from = $cart_info.items item = cart_item}
            {if $cart_item.product_id == $product.id}{assign var = in_cart value = true}{/if}
        {/foreach}
    {/if}
{/if}

{* Price: the sale price when one applies, with the regular price struck through. *}
{$price = 0}
{$old_price = 0}
{if !empty($first_item.apply_special) && !empty($first_item.price_special)}
    {$price = $first_item.price_special}
    {if !empty($first_item.price) && $first_item.price > $first_item.price_special}{$old_price = $first_item.price}{/if}
{elseif !empty($first_item.price)}
    {$price = $first_item.price}
{/if}
{$discount = 0}
{if $old_price > 0}{$discount = round(($old_price - $price) / $old_price * 100)}{/if}
{$price_text = 'Liên hệ'}
{if $price > 0}{$price_text = "{$price|number_format:0:',':'.'}đ"}{/if}
{$old_price_text = ''}
{if $old_price > 0}{$old_price_text = "{$old_price|number_format:0:',':'.'}đ"}{/if}

{* Lessons: chapters ("chapter_vi" = y) group the lessons that follow them. *}
{$raw_lessons = []}
{if !empty($product.attributes.danhsachtiethoc.value)}{$raw_lessons = $product.attributes.danhsachtiethoc.value|json_decode:1}{/if}
{if !is_array($raw_lessons)}{$raw_lessons = []}{/if}
{* Quizzes of the lessons: name and size of each; classroom-quiz.js loads the questions when a quiz starts. *}
{$course_quizzes = $this->Product->getCourseQuizData(['lesson_list' => $raw_lessons])}
{$chapters = []}
{$lessons = []}
{$chapter_index = -1}
{$trial_videos = 0}
{$open_quizzes = 0}
{$any_open_quiz = false}
{$quiz_count = 0}
{* Exam-prep course (category 125): lessons hold their exercises; the review lesson holds source exams. *}
{$exam_prep = !empty($product.main_category_id) && $product.main_category_id == 125}
{$first_open = 0}
{$review_lesson_number = 0}
{foreach from = $raw_lessons item = item}
    {if empty($item.name_vi)}{continue}{/if}
    {$item_title = $item.name_vi|trim}
    {if !empty($item.chapter_vi) && $item.chapter_vi == 'y'}
        {$chapters[] = $item_title}
        {$chapter_index = count($chapters) - 1}
        {continue}
    {/if}
    {if $chapter_index < 0}
        {$chapters[] = 'Bài học'}
        {$chapter_index = 0}
    {/if}

    {$video = ''}
    {if !empty($item.youtube_id_vi)}
        {$video = $item.youtube_id_vi|trim|regex_replace:'/[^\w-].*$/s':''}
        {if strlen($video) != 11}{$video = ''}{/if}
    {/if}
    {$trial = !empty($item.trial_vi) && $item.trial_vi == 'y'}
    {$open = $licensed || $trial}
    {$files = []}
    {if !empty($item.filestwo)}
        {$files = $item.filestwo|json_decode:1}
        {if !is_array($files)}{$files = []}{/if}
    {/if}
    {$lesson_quizzes = $this->Product->getLessonQuizzes($item)}
    {$quizzes = []}
    {$open_quiz = false}
    {$free_quiz = false}
    {foreach from = $lesson_quizzes item = lesson_quiz}
        {if empty($course_quizzes.info[$lesson_quiz.id])}{continue}{/if}
        {$quiz_open = $licensed || $lesson_quiz.free}
        {$quizzes[] = ['id' => $lesson_quiz.id, 'open' => $quiz_open, 'free' => $lesson_quiz.free]}
        {if $quiz_open}{$open_quiz = true}{$any_open_quiz = true}{/if}
        {if $lesson_quiz.free}{$free_quiz = true}{/if}
        {if $lesson_quiz.free && !$licensed}{$open_quizzes = $open_quizzes + 1}{/if}
    {/foreach}
    {$quiz_count = $quiz_count + count($quizzes)}
    {$number = count($lessons) + 1}
    {if $video != '' && $trial && !$licensed}{$trial_videos = $trial_videos + 1}{/if}
    {if $first_open == 0 && (($video != '' && $open) || $open_quiz)}{$first_open = $number}{/if}
    {$access = 'locked'}
    {if $licensed}{$access = 'open'}{elseif $trial}{$access = 'trial'}{/if}
    {$review = !empty($item.review_vi) && $item.review_vi == 'y'}
    {if $review}{$review_lesson_number = $number}{/if}
    {$code = ''}
    {if !empty($item.code)}{$code = $item.code}{/if}

    {$lessons[] = ['number' => $number, 'title' => $item_title, 'chapter' => $chapter_index, 'video' => $video, 'access' => $access, 'trial' => $trial, 'open' => $open, 'files' => $files, 'quizzes' => $quizzes, 'open_quiz' => $open_quiz, 'free_quiz' => $free_quiz, 'quiz_pending' => count($lesson_quizzes) > count($quizzes), 'review' => $review, 'code' => $code]}
{/foreach}
{$lesson_count = count($lessons)}

{* Course facts *}
{$attributes = []}
{if !empty($product.attributes)}{$attributes = $product.attributes}{/if}
{* Keep the same saved course facts as the original MedUC quote card. *}
{$course_duration = $attributes.thoiluong.value|default:''|strip_tags|trim}
{$course_ownership = $attributes.sohuu.value|default:''|strip_tags|trim}
{$course_lessons_text = $attributes.soluongbaihoc.value|default:''|strip_tags|trim}
{$course_exercises_text = $attributes.soluongbaitap.value|default:''|strip_tags|regex_replace:'/\s+chữa\s+chi\s+tiết/iu':''|trim}
{$course_lesson_number = $lesson_count}
{if $course_lessons_text != '' && preg_match('/^[1-9][0-9]*(?:\s|$)/u', $course_lessons_text)}
    {$course_lesson_number = intval($course_lessons_text)}
{/if}
{if $course_lessons_text == '' && $lesson_count > 0}{$course_lessons_text = "{$lesson_count} bài học"}{/if}
{$unit_price = 0}
{if $price > 0 && $course_lesson_number > 0}{$unit_price = round($price / $course_lesson_number)}{/if}
{$consult_url = 'https://zalo.me/0339308997'}
{if !empty($text.link_zalo)}{$consult_url = $text.link_zalo}{/if}
{$intro_video = ''}
{if !empty($attributes.videogioithieu.value)}
    {$intro_video = $attributes.videogioithieu.value|trim|regex_replace:'/[^\w-].*$/s':''}
    {if strlen($intro_video) != 11}{$intro_video = ''}{/if}
{/if}
{$course_files = []}
{if !empty($attributes.tailieudinhkem.value)}
    {$course_files = $attributes.tailieudinhkem.value|json_decode:1}
    {if !is_array($course_files)}{$course_files = []}{/if}
{/if}

{* Student feedback videos for the upper Phản hồi tab *}
{$course_path = "/{$product.url}"}
{$voices = []}
{$voices_general = false}
{$all_voice_items = []}
{$all_voices = $this->Block->getSliderItems('fbvideos')}
{foreach from = $all_voices item = voice}
    {$voice_id = $voice.url|default:''|trim}
    {if !preg_match('/^[\w-]+$/', $voice_id)}
        {$voice_id = $voice_id|regex_replace:'/^.*(?:[?&]v=|youtu\.be\/|\/shorts\/|\/embed\/|\/live\/)([\w-]+).*$/s':'$1'}
    {/if}
    {if strlen($voice_id) != 11 || !preg_match('/^[\w-]+$/', $voice_id)}{continue}{/if}
    {$voice_title = $voice.name|default:'Cảm nhận học viên MedUC'|trim}
    {$voice_subject = $voice.description|default:''|trim}
    {$voice_course = $voice.description_short|default:''|trim}
    {$voice_item = ['id' => $voice_id, 'title' => $voice_title, 'subject' => $voice_subject, 'course' => $voice_course]}
    {if $voice_course == $course_path}{$voices[] = $voice_item}{/if}
    {$all_voice_items[] = $voice_item}
{/foreach}
{if empty($voices) && !empty($all_voice_items)}
    {$voices = array_slice($all_voice_items, 0, 4)}
    {$voices_general = true}
{/if}
{* Feedback on the course page contains videos only. *}
{capture name = mcr_feedback}
    <h3 class="mcr-feedback-title">{if $voices_general}Học viên nói gì về MedUC{else}Học viên nói gì về khoá học này{/if}</h3>
    {if !empty($voices)}
        <div class="mcr-voices">
            {foreach from = $voices item = voice}
                <figure class="mcr-voice">
                    <button type="button" class="mcr-poster mcr-poster--small" data-mcr-embed="{$voice.id}" aria-label="Phát video {$voice.title|escape}">
                        <img src="https://i.ytimg.com/vi/{$voice.id}/hqdefault.jpg" alt="" loading="lazy" decoding="async" />
                        <span class="mcr-play" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M8 5.5v13l11-6.5z" /></svg></span>
                    </button>
                    <figcaption>{if $voice.subject != ''}<span>{$voice.subject|escape}</span>{/if}{$voice.title|escape}</figcaption>
                </figure>
            {/foreach}
        </div>
    {/if}
    <a class="mcr-feedback-all" href="/phan-hoi-hoc-vien">Xem tất cả phản hồi của học viên <span aria-hidden="true">→</span></a>
{/capture}

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/classroom.css?v=20261028-20" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/classroom.js?v=20261028-8" defer></script>
{if $quiz_count > 0}
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/classroom-confidence.css?v=20261028-1" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/classroom-confidence.js?v=20261028-2" defer></script>
{/if}
{if $quiz_count > 0}<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/classroom-quiz.js?v=20261028-mobile-map-1" defer></script>{/if}
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/classroom-contribution.js?v=20261017-3" defer></script>

<section class="mcr" data-mcr data-mcr-licensed="{if $licensed}1{else}0{/if}" data-mcr-count="{$lesson_count}" data-mcr-product="{$product.id}" data-mcr-exam-prep="{if $exam_prep}1{else}0{/if}" data-mcr-member="{if !empty($member_info.id)}{$member_info.id}{/if}" data-mcr-member-code="{$code_member}" data-mcr-class-room="{$class_room_id}" nh-product-detail nh-product="{$product.id}" nh-product-item-id="{if !empty($first_item.id)}{$first_item.id}{/if}" nh-product-attribute-special="{if !empty($product.attributes_item_special)}{htmlentities($product.attributes_item_special|@json_encode)}{/if}">
    <div class="mcr-shell">
        <nav class="mcr-breadcrumb" aria-label="Đường dẫn">
            <a href="/">Trang chủ</a><span aria-hidden="true">›</span>{if $exam_prep}<a href="/khoa-luyen-thi">Luyện thi</a>{else}<a href="/khoa-hoc">Khoá học</a>{/if}<span aria-hidden="true">›</span><span aria-current="page">{$product.name|escape}</span>
        </nav>
        <section class="mcr-course-overview{if $intro_video == '' && empty($product.all_images[0])} mcr-course-overview--text{/if}" data-mcr-overview aria-labelledby="mcr-course-title">
            <header class="mcr-course-heading">
                <p class="mcr-course-eyebrow">{if $exam_prep}Khoá luyện thi{else}Khoá học MedUC{/if}</p>
                <h1 id="mcr-course-title">{$product.name|escape}</h1>
            </header>
            <div class="mcr-intro">
                <div class="mcr-intro-main">
                    <div class="mcr-overview-tabs" role="tablist" aria-label="Thông tin khoá học">
                        <button type="button" role="tab" id="mcr-overview-tab-about" aria-controls="mcr-overview-about" aria-selected="true" data-mcr-overview-tab="about">Giới thiệu</button>
                        <button type="button" role="tab" id="mcr-overview-tab-summary" aria-controls="mcr-overview-summary" aria-selected="false" tabindex="-1" data-mcr-overview-tab="summary">Tổng quan</button>
                        <a class="mcr-overview-jump" href="#mcr-learning" data-mcr-outline-jump>Lộ trình</a>
                        <button type="button" role="tab" id="mcr-overview-tab-feedback" aria-controls="mcr-overview-feedback" aria-selected="false" tabindex="-1" data-mcr-overview-tab="feedback">Phản hồi</button>
                    </div>
                    <div id="mcr-overview-about" role="tabpanel" aria-labelledby="mcr-overview-tab-about" data-mcr-overview-panel="about">
                        <div class="mcr-intro-hero">
                            {if $intro_video != '' || !empty($product.all_images[0])}
                                <div class="mcr-intro-media">
                                    {if $intro_video != ''}
                                        <button type="button" class="mcr-poster" data-mcr-embed="{$intro_video}" aria-label="Phát video giới thiệu khoá học">
                                            <img src="https://i.ytimg.com/vi/{$intro_video}/hqdefault.jpg" alt="" decoding="async" />
                                            <span class="mcr-play" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M8 5.5v13l11-6.5z" /></svg></span>
                                            <span class="mcr-poster-label">Video giới thiệu</span>
                                        </button>
                                    {else}
                                        <img class="mcr-cover" src="{CDN_URL}{$product.all_images[0]}" alt="{$product.name|escape}" />
                                    {/if}
                                </div>
                            {/if}
                        </div>
                        <section class="mcr-section mcr-section--about" aria-label="Giới thiệu khoá học">
                            {if !empty($attributes.motangan.value) || !empty($attributes.motakhoahoc.value)}
                                <p class="mcr-about-preview" data-mcr-description-preview>{if !empty($attributes.motangan.value)}{$attributes.motangan.value|strip_tags|truncate:480:'…':true}{else}{$attributes.motakhoahoc.value|strip_tags|truncate:480:'…':true}{/if}</p>
                                <div class="mcr-richtext" id="mcr-description-full" data-mcr-description-full hidden>
                                    {if !empty($attributes.motangan.value)}<div class="mcr-lead">{$attributes.motangan.value}</div>{/if}
                                    {if !empty($attributes.motakhoahoc.value)}{$attributes.motakhoahoc.value}{/if}
                                </div>
                                <button type="button" class="mcr-read-more" aria-expanded="false" aria-controls="mcr-description-full" data-mcr-description-toggle>Xem thêm <span aria-hidden="true">↓</span></button>
                            {else}
                                <p class="mcr-about-preview">Khám phá lộ trình {$product.name|escape} qua {$lesson_count} bài học. Chọn một bài bên dưới để xem nội dung và bắt đầu học.</p>
                            {/if}
                        </section>
                    </div>
                    <div id="mcr-overview-summary" role="tabpanel" aria-labelledby="mcr-overview-tab-summary" data-mcr-overview-panel="summary" hidden>
                        {if !empty($attributes.anhtongquan.value)}
                            <img class="mcr-overview-image" src="{CDN_URL}{$attributes.anhtongquan.value|escape}" alt="Tổng quan {$product.name|escape}" loading="lazy" decoding="async" />
                        {else}
                            <p class="mcr-empty mcr-overview-pending">Ảnh tổng quan đang được cập nhật.</p>
                        {/if}
                    </div>
                    <div id="mcr-overview-feedback" role="tabpanel" aria-labelledby="mcr-overview-tab-feedback" data-mcr-overview-panel="feedback" hidden>
                        <section class="mcr-section" id="mcr-phan-hoi" aria-label="Phản hồi">
                            <div class="mcr-feedback">{$smarty.capture.mcr_feedback}</div>
                        </section>

                    </div>
                </div>
                    <aside class="mcr-intro-side" aria-label="Đăng ký khoá học">
                        <div class="mcr-buy">
                            {if !$licensed}
                                <div class="mcr-buy-heading"><p class="mcr-buy-eyebrow">Học phí khoá học</p>{if $old_price_text != ''}<span class="mcr-discount">−{$discount}%</span>{/if}</div>
                                <p class="mcr-price"><strong>{$price_text}</strong>{if $old_price_text != ''}<s>{$old_price_text}</s>{/if}</p>
                                {if $unit_price > 0}<p class="mcr-unit-cost"><span>Bình quân</span><strong>{$unit_price|number_format:0:',':'.'}đ/{if $exam_prep}bài{else}buổi{/if}</strong></p>{/if}
                            {else}
                                <p class="mcr-owned"><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="m8 12 3 3 5-6"/></svg>Bạn đã sở hữu khoá học này</p>
                            {/if}
                            <dl class="mcr-specs">
                                {if $course_duration != ''}<div><dt><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg>Thời lượng</dt><dd>{$course_duration|escape}</dd></div>{/if}
                                {if $course_lessons_text != ''}<div><dt><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 4h14v16H5zM8 8h8M8 12h8M8 16h5"/></svg>Số lượng bài học</dt><dd>{$course_lessons_text|escape}</dd></div>{/if}
                                {if $exam_prep}
                                    <div><dt><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 4H5v16h14v-7M10 15l1-4 7-7 3 3-7 7z"/></svg>Số lượng đề</dt><dd>{count($course_quizzes.info)} đề</dd></div>
                                {elseif $course_exercises_text != ''}
                                    <div><dt><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 4H5v16h14v-7M10 15l1-4 7-7 3 3-7 7z"/></svg>Số lượng bài tập</dt><dd>{$course_exercises_text|escape}</dd></div>
                                {/if}
                                {if $course_ownership != ''}<div><dt><svg viewBox="0 0 24 24" aria-hidden="true"><rect x="4" y="5" width="16" height="16" rx="2"/><path d="M8 3v4m8-4v4M4 11h16"/></svg>Sở hữu</dt><dd>{$course_ownership|escape}</dd></div>{/if}
                            </dl>
                            {if !$licensed}
                                <section class="mcr-assurance" aria-label="Cam kết hoàn học phí">
                                    <h3 class="mcr-assurance-title"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="m12 3 8 3v6c0 5-8 9-8 9s-8-4-8-9V6z"/><path d="m8 12 3 3 5-6"/></svg>Cam kết hoàn học phí</h3>
                                    <ul>
                                        <li>Học <strong>3 ngày</strong> không hiệu quả, <strong>hoàn 100% học phí.</strong></li>
                                        <li>Hoàn thành <strong>80% khoá học</strong>, làm đúng <strong>80% bài tập</strong> nhưng thi dưới <strong>điểm B</strong>, <strong>hoàn 100% học phí.</strong></li>
                                    </ul>
                                </section>
                            {/if}
                            <div class="mcr-buy-actions">
                                {if !$licensed}
                                    <a class="mcr-btn mcr-btn--primary mcr-btn--block" {if $in_cart}href="/order/info"{else}href="javascript:;" nh-btn-action="add-cart" nh-redirect="/order/info"{/if}>Đăng ký học ngay</a>
                                    <a class="mcr-btn mcr-btn--ghost mcr-btn--block" href="{$consult_url|escape}" target="_blank" rel="noopener noreferrer">Tư vấn trên Zalo</a>
                                {else}
                                    {if $first_open > 0}<a class="mcr-btn mcr-btn--primary mcr-btn--block" href="?bai={$first_open}" data-mcr-start="{$first_open}"><span data-mcr-start-label>Vào học</span><span aria-hidden="true">→</span></a>{/if}
                                    <a class="mcr-btn mcr-btn--ghost mcr-btn--block" href="/member/classroom">Lớp học của tôi</a>
                                {/if}
                            </div>
                        </div>
                    </aside>
            </div>
        </section>

        <header class="mcr-learning-heading" id="mcr-learning">
            <div><p class="mcr-course-eyebrow">Học theo lộ trình</p><h2>Nội dung khoá học</h2></div>
            <span>{$lesson_count} bài học</span>
        </header>

        <div class="mcr-layout" data-mcr-classroom>
            {* Course outline *}
            <aside class="mcr-sidebar" aria-label="Lộ trình học">
                <div class="mcr-outline-actions">
                    <h3>Chương trình học</h3>
                    {if $exam_prep && $review_lesson_number > 0}<button type="button" class="mcr-mock-exam" data-mcr-mock-exam="{$review_lesson_number}">Thi thử</button>{/if}
                </div>
                <div class="mcr-outline">
                    {foreach from = $chapters key = chapter_key item = chapter_title}
                        {$chapter_size = 0}
                        {foreach from = $lessons item = lesson}{if $lesson.chapter == $chapter_key}{$chapter_size = $chapter_size + 1}{/if}{/foreach}
                        {if $chapter_size == 0}{continue}{/if}
                        <details class="mcr-chapter" open>
                            <summary>
                                <span class="mcr-chapter-number">{($chapter_key + 1)|string_format:'%02d'}</span>
                                <span class="mcr-chapter-title">{$chapter_title|escape}<small>{$chapter_size} bài</small></span>
                                <svg class="mcr-chevron" viewBox="0 0 24 24" aria-hidden="true"><path d="m6 9 6 6 6-6" /></svg>
                            </summary>
                            <ol class="mcr-lessons">
                                {foreach from = $lessons item = lesson}
                                    {if $lesson.chapter != $chapter_key}{continue}{/if}
                                    <li>
                                        <a class="mcr-lesson" href="?bai={$lesson.number}" data-mcr-lesson="{$lesson.number}" data-video="{$lesson.video}" data-access="{$lesson.access}" data-trial="{if $lesson.trial}1{else}0{/if}" data-free-quiz="{if $lesson.free_quiz}1{else}0{/if}" data-title="{$lesson.title|escape}" data-chapter="{$chapter_title|escape}" data-quiz="{if $lesson.open_quiz}1{else}0{/if}" data-quizzes="{count($lesson.quizzes)}">
                                            <span class="mcr-lesson-number">{$lesson.number|string_format:'%02d'}</span>
                                            <span class="mcr-lesson-title">{$lesson.title|escape}</span>
                                            {if $lesson.access == 'trial' || $lesson.free_quiz}
                                                <span class="mcr-tag mcr-tag--free">Free</span>
                                            {else}
                                                <span class="mcr-tag mcr-tag--pro">Pro</span>
                                            {/if}
                                        </a>
                                    </li>
                                {/foreach}
                            </ol>
                        </details>
                    {/foreach}
                </div>
            </aside>

            <div class="mcr-main">
                {* Lesson: filled in by classroom.js from the outline *}
                <div class="mcr-view mcr-lesson-view" data-mcr-view="lesson" hidden>
                    <h2 class="mcr-sr-only" data-mcr-heading></h2>
                    <div class="mcr-toolbar">
                        <div class="mcr-tabs" role="tablist" aria-label="Nội dung bài học">
                            {if $exam_prep}
                                <button type="button" role="tab" id="mcr-tab-quiz" aria-controls="mcr-panel-quiz" aria-selected="true" data-mcr-tab="quiz">Luyện đề</button>
                                <button type="button" role="tab" id="mcr-tab-video" aria-controls="mcr-panel-video" aria-selected="false" tabindex="-1" data-mcr-tab="video">Video chữa bài</button>
                                <button type="button" role="tab" id="mcr-tab-files" aria-controls="mcr-panel-files" aria-selected="false" tabindex="-1" data-mcr-tab="files">Tài liệu</button>
                            {else}
                                <button type="button" role="tab" id="mcr-tab-video" aria-controls="mcr-panel-video" aria-selected="true" data-mcr-tab="video">Video</button>
                                <button type="button" role="tab" id="mcr-tab-files" aria-controls="mcr-panel-files" aria-selected="false" tabindex="-1" data-mcr-tab="files">Tài liệu</button>
                                <button type="button" role="tab" id="mcr-tab-quiz" aria-controls="mcr-panel-quiz" aria-selected="false" tabindex="-1" data-mcr-tab="quiz">Bài tập</button>
                            {/if}
                            <a class="mcr-tab-jump" href="#mcr-course-title" data-mcr-back-to-intro>Giới thiệu</a>
                        </div>
                        {if $licensed}<span class="mcr-toolbar-progress" data-mcr-progress></span>{/if}
                    </div>

                    <div class="mcr-panel" id="mcr-panel-video" role="tabpanel" aria-labelledby="mcr-tab-video" data-mcr-panel="video"{if $exam_prep} hidden{/if}>
                        <div class="mcr-stage">
                            <div class="mcr-stage-poster" data-mcr-stage="poster">
                                <img alt="" data-mcr-poster />
                                <button type="button" class="mcr-stage-play" data-mcr-play-lesson>
                                    <span class="mcr-play" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M8 5.5v13l11-6.5z" /></svg></span>
                                    <span>Phát bài giảng</span>
                                </button>
                            </div>
                            <div class="mcr-stage-player" data-mcr-stage="player" hidden><div data-mcr-player></div></div>
                            <div class="mcr-stage-card" data-mcr-stage="paywall" hidden>
                                <svg class="mcr-card-icon" viewBox="0 0 24 24" aria-hidden="true"><rect x="5" y="10.5" width="14" height="10" rx="2" /><path d="M8 10.5V7.5a4 4 0 0 1 8 0v3" /></svg>
                                <h3 data-mcr-paywall-title>Buổi này dành cho học viên đã đăng ký</h3>
                                <p data-mcr-paywall-text>Đăng ký để học trọn {$lesson_count} bài của khoá học.</p>
                                {if !$licensed}
                                    <p class="mcr-price mcr-price--center"><strong>{$price_text}</strong>{if $old_price_text != ''}<s>{$old_price_text}</s><span class="mcr-discount">−{$discount}%</span>{/if}</p>
                                    <div class="mcr-card-actions">
                                        <a class="mcr-btn mcr-btn--primary" {if $in_cart}href="/order/info"{else}href="javascript:;" nh-btn-action="add-cart" nh-redirect="/order/info"{/if}>Đăng ký khóa học</a>
                                        <button type="button" class="mcr-btn mcr-btn--ghost-light" data-mcr-paywall-next hidden>Xem video học thử tiếp</button>
                                        {if !empty($text.link_zalo)}<a class="mcr-btn mcr-btn--ghost-light" href="{$text.link_zalo|escape}" target="_blank" rel="noopener noreferrer">Tư vấn trên Zalo</a>{/if}
                                    </div>
                                    <button type="button" class="mcr-card-link" data-mcr-goto-quiz hidden>Buổi này có bài tập làm thử miễn phí →</button>
                                {/if}
                            </div>
                            <div class="mcr-stage-card" data-mcr-stage="novideo" hidden>
                                <svg class="mcr-card-icon" viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="5" width="18" height="14" rx="2" /><path d="m10 9 5 3-5 3z" /></svg>
                                <h3>Buổi này học trên ClassIn</h3>
                                <p>Video buổi học nằm trong lớp ClassIn của bạn. Tài liệu và bài tập của buổi này có ngay trong các tab bên dưới.</p>
                                <div class="mcr-card-actions">
                                    <button type="button" class="mcr-btn mcr-btn--primary" data-mcr-goto-quiz-novideo hidden>Làm bài tập buổi này</button>
                                    <a class="mcr-btn mcr-btn--ghost-light" href="/member/classroom">Khoá học của tôi</a>
                                </div>
                            </div>
                            <div class="mcr-stage-card" data-mcr-stage="error" hidden>
                                <svg class="mcr-card-icon" viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="5" width="18" height="14" rx="2" /><path d="M12 9v4M12 16v.5" /></svg>
                                <h3>Video buổi này tạm thời chưa xem được</h3>
                                <p>MedUC đang cập nhật lại video này. Bạn có thể học bài khác hoặc làm bài tập của buổi này.</p>
                                <div class="mcr-card-actions">
                                    <button type="button" class="mcr-btn mcr-btn--primary" data-mcr-error-next>Sang bài tiếp theo</button>
                                    <button type="button" class="mcr-btn mcr-btn--ghost-light" data-mcr-goto-quiz-error hidden>Làm bài tập buổi này</button>
                                </div>
                            </div>
                            {* Exam-prep lessons have no video yet: a placeholder that leads to the exams. *}
                            <div class="mcr-stage-card" data-mcr-stage="soon" hidden>
                                <svg class="mcr-card-icon" viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="5" width="18" height="14" rx="2" /><path d="m10 9 5 3-5 3z" /></svg>
                                <p class="mcr-card-kicker">Video chữa đề</p>
                                <h3>Video bài giảng sắp có</h3>
                                <p>MedUC đang chuẩn bị video cho phần này. Nếu bài tập đã có câu hỏi, bạn có thể làm ở tab Bài tập.</p>
                                <div class="mcr-card-actions">
                                    <button type="button" class="mcr-btn mcr-btn--primary" data-mcr-goto-quiz-soon hidden>Làm đề ngay</button>
                                </div>
                            </div>
                            <div class="mcr-stage-card" data-mcr-stage="end" hidden>
                                <p class="mcr-card-kicker">Bài tiếp theo</p>
                                <h3 data-mcr-end-title></h3>
                                <p data-mcr-end-count></p>
                                <div class="mcr-card-actions">
                                    <button type="button" class="mcr-btn mcr-btn--primary" data-mcr-end-next>Học tiếp ngay</button>
                                    <button type="button" class="mcr-btn mcr-btn--ghost-light" data-mcr-end-stay>Ở lại bài này</button>
                                </div>
                            </div>
                        </div>
                        <div class="mcr-lesson-nav">
                            <button type="button" class="mcr-nav-button" data-mcr-prev><span aria-hidden="true">←</span> Bài trước</button>
                            <span class="mcr-position" data-mcr-position></span>
                            <button type="button" class="mcr-nav-button" data-mcr-next>Bài tiếp <span aria-hidden="true">→</span></button>
                        </div>
                    </div>

                    <div class="mcr-panel" id="mcr-panel-files" role="tabpanel" aria-labelledby="mcr-tab-files" data-mcr-panel="files" hidden>
                        {foreach from = $lessons item = lesson}
                            <div class="mcr-resource" data-mcr-files="{$lesson.number}" hidden>
                                {if empty($lesson.files)}
                                    <p class="mcr-empty">Buổi này chưa có tài liệu riêng.</p>
                                {elseif !$lesson.open}
                                    <p class="mcr-empty mcr-empty--locked">Tài liệu của buổi này dành cho học viên đã đăng ký.</p>
                                {else}
                                    <ul class="mcr-files">
                                        {foreach from = $lesson.files item = file}
                                            {$file_name = $this->Utilities->getFileNameInUrl($file)|urldecode}
                                            <li><a href="javascript:;" btn-view-file data-bs-toggle="modal" data-bs-target="#previewFile" data-file="https://meduc.vn/cdn{$this->Utilities->checkInternalUrl($file)}" data-name="{$file_name|escape}"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M14 3H6v18h12V7z" /><path d="M14 3v4h4" /></svg>{$file_name|escape}</a></li>
                                        {/foreach}
                                    </ul>
                                {/if}
                            </div>
                        {/foreach}
                    </div>

                    <div class="mcr-panel" id="mcr-panel-quiz" role="tabpanel" aria-labelledby="mcr-tab-quiz" data-mcr-panel="quiz"{if !$exam_prep} hidden{/if}>
                        {foreach from = $lessons item = lesson}
                            <div class="mcr-resource" data-mcr-quiz="{$lesson.number}" hidden>
                                {if empty($lesson.quizzes)}
                                    <p class="mcr-empty">{if $lesson.quiz_pending}Bài tập của buổi này đang được cập nhật.{else}Buổi này chưa có bài tập trắc nghiệm.{/if}</p>
                                {else}
                                    {$quiz_total = count($lesson.quizzes)}
                                    {if $quiz_total > 8}
                                        <div class="mcr-quiz-filter">
                                            <input type="search" placeholder="Tìm trong {$quiz_total} đề của buổi này…" aria-label="Tìm đề" data-mcr-quiz-filter autocomplete="off">
                                            <span data-mcr-quiz-filter-count>{$quiz_total} đề</span>
                                        </div>
                                    {/if}
                                    <div class="mcr-quiz-list">
                                        {foreach from = $lesson.quizzes item = quiz}
                                            {$quiz_info = $course_quizzes.info[$quiz.id]}
                                            <div class="mcr-quiz-card{if !$quiz.open} is-locked{/if}">
                                                <div>
                                                    <p class="mcr-quiz-kicker">{if $lesson.review}Đề thi thử{else}Bài tập trắc nghiệm{/if}{if $quiz_total > 1} {$quiz@iteration}/{$quiz_total}{/if}{if !$licensed && $quiz.free}<span class="mcr-quiz-free">Làm thử miễn phí</span>{/if}</p>
                                                    <h3>{$quiz_info.name|escape}</h3>
                                                    <p>{$quiz_info.count} câu{if $quiz_info.minutes > 0} · {$quiz_info.minutes} phút{/if} · {if $quiz.open}Nộp bài là có điểm và lời giải chi tiết.{else}Dành cho học viên đã đăng ký khoá học.{/if}</p>
                                                </div>
                                                <div class="mcr-quiz-actions">
                                                <button type="button" class="mcr-btn mcr-btn--ghost" data-mcr-quiz-history="{$quiz.id}" data-mcr-quiz-free="{if $quiz.free}1{else}0{/if}" {if !$quiz.open}hidden{/if} data-lesson="{$lesson.number}" data-lesson-title="{$lesson.title|escape}" data-lesson-code="{$lesson.code|escape}">Lịch sử</button>
                                                <button type="button" class="mcr-btn mcr-btn--primary" data-mcr-quiz-start="{$quiz.id}" data-mcr-quiz-free="{if $quiz.free}1{else}0{/if}" {if !$quiz.open}hidden{/if} data-lesson="{$lesson.number}" data-lesson-title="{$lesson.title|escape}" data-lesson-code="{$lesson.code|escape}">Làm bài</button>
                                                <a data-mcr-quiz-enroll {if $quiz.open}hidden{/if} class="mcr-btn mcr-btn--ghost" {if $in_cart}href="/order/info"{else}href="javascript:;" nh-btn-action="add-cart" nh-redirect="/order/info"{/if}>
                                                        <svg class="mcr-lock" viewBox="0 0 24 24" aria-hidden="true"><rect x="5" y="10.5" width="14" height="10" rx="2" /><path d="M8 10.5V7.5a4 4 0 0 1 8 0v3" /></svg>
                                                        Đăng ký để làm
                                                    </a>
                                                </div>
                                            </div>
                                        {/foreach}
                                    </div>
                                {/if}
                            </div>
                        {/foreach}
                        {* classroom-quiz.js builds the quiz here; the lesson's card above hides while it runs. *}
                        <div class="mcq" data-mcr-quiz-player hidden></div>
                        <p class="mcr-quiz-disclaimer" data-mcr-policy>Bộ đề được đội ngũ ThS, BSNT của MedUC tổng hợp, rà soát và giải đáp, có hỗ trợ một phần của AI. Nội dung có thể còn sai sót; MedUC trân trọng mọi góp ý về đề, đáp án và lộ trình học.</p>
                        <details class="mcr-contribution" data-mcr-contribution>
                            <summary>Góp ý đáp án, lộ trình hoặc đóng góp đề <span aria-hidden="true">→</span></summary>
                            <div class="mcr-contribution-body">
                                <p class="mcr-contribution-intro">Học xong, bạn thấy đáp án hoặc lộ trình có điểm nào cần sửa? Bạn có đề muốn chia sẻ với cộng đồng học Y?</p>
                                {if empty($member_info.id)}
                                    <p>Vui lòng <a href="javascript:;" data-bs-toggle="modal" data-bs-target="#login-modal">đăng nhập</a> để gửi đóng góp.</p>
                                {else}
                                    <form data-mcr-contribution-form enctype="multipart/form-data">
                                        <input type="hidden" name="product_id" value="{$product.id}">
                                        <input type="hidden" name="lesson_number" value="" data-contribution-lesson>
                                        <div class="mcr-contribution-grid">
                                            <label>Loại đóng góp
                                                <select name="type" required data-contribution-type>
                                                    <option value="answer">Góp ý đáp án / lời giải</option>
                                                    <option value="exam">Đóng góp đề dạng ảnh chụp</option>
                                                    <option value="curriculum">Góp ý lộ trình, chương, bài</option>
                                                    <option value="general">Góp ý khác</option>
                                                </select>
                                            </label>
                                            <label data-contribution-quiz-field>Đề cần góp ý
                                                <select name="quiz_id" data-contribution-quiz><option value="">Chọn đề trong bài này</option></select>
                                            </label>
                                            <label data-contribution-question-field>Số câu
                                                <input type="number" min="1" name="question_number" placeholder="Ví dụ: 12">
                                            </label>
                                            <label data-contribution-answer-field>Đáp án đề xuất
                                                <input type="text" maxlength="255" name="suggested_answer" placeholder="Ví dụ: B">
                                            </label>
                                        </div>
                                        <label class="mcr-contribution-wide" data-contribution-photo-field hidden>Ảnh đề (tối đa 5 ảnh, mỗi ảnh dưới 8 MB)
                                            <input type="file" name="photos[]" accept="image/jpeg,image/png,image/webp" multiple>
                                        </label>
                                        <label class="mcr-contribution-wide">Nội dung đóng góp
                                            <textarea name="content" rows="4" minlength="10" maxlength="5000" required placeholder="Mô tả điều cần sửa, lý do hoặc thông tin về đề bạn muốn chia sẻ..."></textarea>
                                        </label>
                                        <div class="mcr-contribution-footer"><button type="submit" class="mcr-btn mcr-btn--primary">Gửi đóng góp</button><span data-contribution-status role="status" aria-live="polite"></span></div>
                                    </form>
                                {/if}
                            </div>
                        </details>
                        <a class="mcr-quiz-rank" href="/class-rank?khoa={$product.id}">Bảng xếp hạng và chỉ số tiến bộ của bạn <span aria-hidden="true">→</span></a>
                    </div>


                </div>
            </div>
        </div>
        <div class="mcr-slot mcr-slot--related mcr-related-courses" data-mcr-slot="sw780fy"></div>
    </div>

    {* PDF files keep using the site's own preview (assets/js/custom.js). *}
    <div class="modal fade modal-preview-file" id="previewFile" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-xl">
            <div class="modal-content">
                <div class="modal-header">
                    <div class="modal-title fs-16">Tài liệu: <span></span></div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
                </div>
                <div class="modal-body"><div id="pdf_container" class="pdf-container"></div></div>
            </div>
        </div>
    </div>
</section>
{else}
    <p class="text-center font-danger mt-10">{__d('template', 'thong_tin_san_pham_khong_ton_tai')}</p>
{/if}
{/strip}
