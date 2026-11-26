{strip}
{* Course information appears above the classroom with Giới thiệu / Tổng quan / Phản hồi tabs.
   Tổng quan displays only the course image attribute anhtongquan, selected in the product admin.
   The curriculum lists per-lesson actions; the existing lesson tabs and players live in one large modal.
   Lessons and access come from Danh sách tiết học and MemberHelper::getCourseAccess.
   Quizzes use App\Lib\LessonQuizzes and classroom-quiz.js; locked questions are never sent to the page.
   Student feedback videos come from fbvideos; sign-up uses the existing cart.
   Block text keys: link_zalo, loi_moi, ghi_chu_bai_tap. *}
{assign var = product value = []}
{if !empty($data_block.data)}{assign var = product value = $data_block.data}{/if}
{assign var = text value = []}
{if !empty($data_extend.locale[{LANGUAGE}])}{assign var = text value = $data_extend.locale[{LANGUAGE}]}{/if}

{$course_kind = $this->Product->courseKind($product.id|default:0)}
{if !empty($product) && $course_kind != 'fa'}
{$quiz_course = $course_kind == 'quiz'}
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
{$entry_offer = $this->Product->startingCourseOffer($product.id)}
{if $entry_offer}
    {$price = $entry_offer.amount}{$old_price = 0}
    {if $entry_offer.price > $entry_offer.amount}{$old_price = $entry_offer.price}{/if}
{/if}
{$discount = 0}
{if $old_price > 0}{$discount = round(($old_price - $price) / $old_price * 100)}{/if}
{$price_text = 'Liên hệ'}
{if $price > 0}{$price_text = "{$price|number_format:0:',':'.'}đ"}{/if}
{if $quiz_course && !empty($entry_offer.duration_months)}{$price_text = "{$price_text}/{$entry_offer.duration_months} tháng"}{/if}
{$old_price_text = ''}
{if $old_price > 0}{$old_price_text = "{$old_price|number_format:0:',':'.'}đ"}{/if}

{* Lessons: chapters ("chapter_vi" = y) group the lessons that follow them. *}
{$raw_lessons = []}
{if !empty($product.attributes.danhsachtiethoc.value)}{$raw_lessons = $product.attributes.danhsachtiethoc.value|json_decode:1}{/if}
{if !is_array($raw_lessons)}{$raw_lessons = []}{/if}
{* Quizzes of the lessons: name and size of each; classroom-quiz.js loads the questions when a quiz starts. *}
{$course_quizzes = $this->Product->getCourseQuizData(['lesson_list' => $raw_lessons, 'product_id' => $product.id])}
{$units = []}
{$unit_index = -1}
{$chapter_units = []}
{$chapters = []}
{$lessons = []}
{$chapter_index = -1}
{$trial_videos = 0}
{$open_quizzes = 0}
{$any_open_quiz = false}
{$quiz_count = 0}
{$ready_exam_types = []}
{* Exam-prep course (category 125): lessons hold their exercises; the review lesson holds source exams. *}
{$exam_prep = $quiz_course}
{$first_open = 0}
{$review_lesson_number = 0}
{$number = 0}
{$lesson_type_labels = ['regular' => 'Bài thường', 'midterm' => 'Giữa kỳ', 'final' => 'Cuối kỳ', 'practical' => 'Thực hành']}
{foreach from = $raw_lessons item = item}
    {if empty($item.name_vi)}{continue}{/if}
    {$item_title = $item.name_vi|trim}
    {$outline_type = $this->Product->getLessonOutlineType($item)}
    {if $outline_type == 'unit'}
        {$units[] = $item_title}
        {$unit_index = count($units) - 1}
        {$chapter_index = -1}
        {continue}
    {/if}
    {if $outline_type == 'chapter'}
        {$chapters[] = $item_title}
        {$chapter_index = count($chapters) - 1}
        {$chapter_units[$chapter_index] = $unit_index}
        {continue}
    {/if}
    {* Keep the original lesson number used in links and quiz history. *}
    {$number = $number + 1}
    {$lesson_type = $item.lesson_type|default:'regular'}
    {if $quiz_course && $lesson_type == 'practical'}{continue}{/if}
    {if $chapter_index < 0}
        {$chapters[] = 'Bài học'}
        {$chapter_index = count($chapters) - 1}
        {$chapter_units[$chapter_index] = $unit_index}
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
    {$lesson_quizzes = $this->Product->getLessonQuizzes($item, $course_kind)}
    {$quizzes = []}
    {$open_quiz = false}
    {$free_quiz = false}
    {foreach from = $lesson_quizzes item = lesson_quiz}
        {if empty($course_quizzes.info[$lesson_quiz.id])}{continue}{/if}
        {$quiz_ready = $course_quizzes.info[$lesson_quiz.id].count > 0}
        {if $quiz_course && $quiz_ready && empty($course_quizzes.info[$lesson_quiz.id].read_only)}
            {$ready_exam_types[$lesson_quiz.id] = $lesson_type}
        {/if}
        {$quiz_open = ($licensed || $lesson_quiz.free) && $quiz_ready}
        {$quizzes[] = ['id' => $lesson_quiz.id, 'open' => $quiz_open, 'free' => $lesson_quiz.free, 'ready' => $quiz_ready]}
        {if $quiz_open}{$open_quiz = true}{$any_open_quiz = true}{/if}
        {if $lesson_quiz.free}{$free_quiz = true}{/if}
        {if $lesson_quiz.free && !$licensed}{$open_quizzes = $open_quizzes + 1}{/if}
    {/foreach}
    {$quiz_count = $quiz_count + count($quizzes)}
    {if $video != '' && $trial && !$licensed}{$trial_videos = $trial_videos + 1}{/if}
    {if $first_open == 0 && (($video != '' && $open) || $open_quiz)}{$first_open = $number}{/if}
    {$access = 'locked'}
    {if $licensed}{$access = 'open'}{elseif $trial}{$access = 'trial'}{/if}
    {$lesson_tags = $item.tags|default:[]}
    {$review = in_array($lesson_type, ['midterm', 'final', 'practical'])}
    {if $review}{$review_lesson_number = $number}{/if}
    {$code = ''}
    {if !empty($item.code)}{$code = $item.code}{/if}

    {$lessons[] = ['number' => $number, 'title' => $item_title, 'chapter' => $chapter_index, 'video' => $video, 'access' => $access, 'trial' => $trial, 'open' => $open, 'files' => $files, 'quizzes' => $quizzes, 'open_quiz' => $open_quiz, 'free_quiz' => $free_quiz, 'quiz_pending' => count($lesson_quizzes) > count($quizzes), 'exam' => $review, 'lesson_type' => $lesson_type, 'tags' => $lesson_tags, 'code' => $code]}
{/foreach}
{$lesson_count = count($lessons)}

{* Course facts *}
{$attributes = []}
{if !empty($product.attributes)}{$attributes = $product.attributes}{/if}
{* Keep the same saved course facts as the original MedUC quote card. *}
{$course_duration = $attributes.thoiluong.value|default:''|strip_tags|trim}
{$course_ownership = $attributes.sohuu.value|default:''|strip_tags|trim}
{$course_lessons_text = $attributes.soluongbaihoc.value|default:''|strip_tags|trim}
{$course_lesson_number = $lesson_count}
{if $course_lessons_text != '' && preg_match('/^[1-9][0-9]*(?:\s|$)/u', $course_lessons_text)}
    {$course_lesson_number = intval($course_lessons_text)}
{/if}
{if $course_lessons_text == '' && $lesson_count > 0}{$course_lessons_text = "{$lesson_count} bài học"}{/if}
{$unit_price = 0}
{if !$quiz_course && $price > 0 && $course_lesson_number > 0}{$unit_price = round($price / $course_lesson_number)}{/if}
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

{$course_instructors = []}
{$course_formats = []}
{if !$quiz_course}
    {$course_instructors = $this->Article->courseInstructorNames($attributes.thongtingiangvien.value|default:'')}
    {if array_filter(array_column($lessons, 'video'))}
        {if $course_kind == 'exam_solution'}
            {$course_formats[] = 'Video chữa đề theo môn'}
        {else}
            {$course_formats[] = 'Video bài giảng theo lộ trình'}
        {/if}
    {/if}
    {if $course_files || array_filter(array_column($lessons, 'files'))}{$course_formats[] = 'Tài liệu đi kèm'}{/if}
    {if !empty($entry_offer.duration_months)}{$course_ownership = "{$entry_offer.duration_months} tháng"}{/if}
{/if}

{* One registration card stays beside both the overview and curriculum. *}
{capture name=mcr_quote}
    <div class="mcr-buy">
        {if $licensed}
            <p class="mcr-owned"><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="m8 12 3 3 5-6"/></svg>{if $quiz_course}Bạn đã có quyền truy cập môn này{else}Bạn đã sở hữu khoá học này{/if}</p>
        {else}
            <h2 class="mcr-buy-title">{if $quiz_course}Quyền lợi gói Đề thi{else}Quyền lợi khóa học{/if}</h2>
        {/if}
        {if $quiz_course}
            {if $ready_exam_types}
                {$exam_counts = array_count_values($ready_exam_types)}
                <dl class="mcr-specs">
                    {if !empty($exam_counts.regular)}<div><dt>Đề theo bài</dt><dd>{$exam_counts.regular} đề</dd></div>{/if}
                    {if !empty($exam_counts.midterm)}<div><dt>Thi thử giữa kỳ</dt><dd>{$exam_counts.midterm} đề</dd></div>{/if}
                    {if !empty($exam_counts.final)}<div><dt>Thi thử cuối kỳ</dt><dd>{$exam_counts.final} đề</dd></div>{/if}
                </dl>
            {else}
                <p class="mcr-quote-note">Đề của môn này đang được cập nhật.</p>
            {/if}
        {else}
            <dl class="mcr-specs">
                {if $course_instructors}<div><dt>Giảng viên</dt><dd>{implode(', ', $course_instructors)|escape}</dd></div>{/if}
                {if $course_lessons_text != ''}<div><dt>Số buổi</dt><dd>{$course_lessons_text|escape}</dd></div>{/if}
                {if $course_formats}<div><dt>Nội dung</dt><dd>{implode(' · ', $course_formats)|escape}</dd></div>{/if}
                {if $course_duration != ''}<div><dt>Thời lượng</dt><dd>{$course_duration|escape}</dd></div>{/if}
                {if $course_ownership != ''}<div><dt>Quyền học</dt><dd>{$course_ownership|escape}</dd></div>{/if}
            </dl>
        {/if}
        {if !$licensed}
            {if !empty($entry_offer.lines)}
                <ul class="mcr-plan-benefits">
                    {foreach $entry_offer.lines as $line}<li><span aria-hidden="true">✓</span>{$line|escape}</li>{/foreach}
                </ul>
            {/if}
            {if !$quiz_course}
                <section class="mcr-assurance" aria-label="Cam kết học tập">
                    <h3 class="mcr-assurance-title"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="m12 3 8 3v6c0 5-8 9-8 9s-8-4-8-9V6z"/><path d="m8 12 3 3 5-6"/></svg>Cam kết học tập</h3>
                    {$this->element('course_price/guarantees')}
                </section>
            {/if}
            <div class="mcr-buy-payment">
                <div class="mcr-buy-heading"><p class="mcr-buy-eyebrow">{if $quiz_course}Giá gói Đề thi{else}Học phí khoá học{/if}</p>{if $old_price_text != ''}<span class="mcr-discount">−{$discount}%</span>{/if}</div>
                <p class="mcr-price"><strong>{$price_text}</strong>{if $old_price_text != ''}<s>{$old_price_text}</s>{/if}</p>
                {if $unit_price > 0}<p class="mcr-unit-cost"><span>Bình quân</span><strong>{$unit_price|number_format:0:',':'.'}đ/buổi</strong></p>{/if}
            </div>
        {/if}
        <div class="mcr-buy-actions">
            {if !$licensed}
                <a class="mcr-btn mcr-btn--primary mcr-btn--block" {if $in_cart}href="/order/info"{else}href="javascript:;" nh-btn-action="add-cart" nh-redirect="/order/info"{/if}>{if $quiz_course}Chọn gói đề thi{else}Đăng ký học ngay{/if}</a>
                <a class="mcr-btn mcr-btn--ghost mcr-btn--block mcr-btn--zalo" href="{$consult_url|escape}" target="_blank" rel="noopener noreferrer">Tư vấn trên Zalo</a>
            {else}
                {if $first_open > 0}<a class="mcr-btn mcr-btn--primary mcr-btn--block" href="?bai={$first_open}" data-mcr-start="{$first_open}"><span data-mcr-start-label>Vào học</span><span aria-hidden="true">→</span></a>{/if}
                <a class="mcr-btn mcr-btn--ghost mcr-btn--block" href="/member/classroom">Lớp học của tôi</a>
            {/if}
        </div>
    </div>
{/capture}

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
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/classroom.css?v=20261125-related-cards" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/classroom.js?v=20261125-course" defer></script>
{if $quiz_count > 0}
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/classroom-confidence.css?v=20261028-1" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/classroom-confidence.js?v=20261028-2" defer></script>
{/if}
{if $quiz_count > 0}<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/classroom-quiz.js?v=20261125-course" defer></script>{/if}
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/classroom-contribution.js?v=20261114-stacked-modal" defer></script>

<section class="mcr" data-mcr data-mcr-kind="{$course_kind|escape}"{if $quiz_course} data-mcr-outline-mode="regular"{/if} data-mcr-licensed="{if $licensed}1{else}0{/if}" data-mcr-count="{$lesson_count}" data-mcr-product="{$product.id}" data-access-expires="{$course_access.expires_at|default:0}" data-mcr-exam-prep="{if $exam_prep}1{else}0{/if}" data-mcr-member="{if !empty($member_info.id)}{$member_info.id}{/if}" data-mcr-member-code="{$code_member}" data-mcr-class-room="{$class_room_id}" nh-product-detail nh-product="{$product.id}" nh-product-item-id="{if !empty($first_item.id)}{$first_item.id}{/if}" nh-product-attribute-special="{if !empty($product.attributes_item_special)}{htmlentities($product.attributes_item_special|@json_encode)}{/if}">
    <div class="mcr-shell">
        <header class="mcr-course-heading">
            <p class="mcr-course-eyebrow">{if $quiz_course}Đề thi{elseif $course_kind == 'exam_solution'}Khoá chữa đề{else}Khoá ôn kiến thức{/if}</p>
            <h1 id="mcr-course-title">{$product.name|escape}</h1>
        </header>
        <div class="mcr-course-columns{if $quiz_course} mcr-course-columns--quiz{/if}">
        {if !$quiz_course}
        <section class="mcr-course-overview{if $intro_video == '' && empty($product.all_images[0])} mcr-course-overview--text{/if}" data-mcr-overview aria-labelledby="mcr-course-title">
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
                                <div class="mcr-about-preview mcr-richtext" data-mcr-description-preview>{if !empty($attributes.motangan.value)}{$attributes.motangan.value|strip_tags|truncate:480:'…':true}{else}{$attributes.motakhoahoc.value|strip_tags|truncate:480:'…':true}{/if}</div>
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
            </div>
        </section>

        {/if}
        <aside class="mcr-course-price" aria-label="{if $quiz_course}Đăng ký gói đề thi{else}Đăng ký khoá học{/if}">{$smarty.capture.mcr_quote}</aside>
        <div class="mcr-course-curriculum" id="mcr-learning">

        <div class="mcr-curriculum-layout" data-mcr-classroom>
            {* Course outline *}
            <aside class="mcr-sidebar mcr-curriculum" aria-label="Lộ trình học">
                <div class="mcr-outline-actions{if $quiz_course} mcr-outline-actions--quiz{/if}"{if $quiz_course} role="group" aria-label="Loại đề thi"{/if}>
                    {if $quiz_course}
                        <button type="button" class="mcr-mock-exam" data-mcr-lesson-exams aria-pressed="true" aria-controls="mcr-outline">Đề theo bài</button>
                    {else}<h3>Chương trình học</h3>{/if}
                    {if $exam_prep}<button type="button" class="mcr-mock-exam" data-mcr-mock-exam="{$review_lesson_number}" aria-pressed="false" aria-controls="mcr-outline">Thi thử</button>{/if}
                    {if $exam_prep}<p class="mcr-mock-pending" data-mcr-mock-pending role="status" hidden>Đang cập nhật đề thi thử.</p>{/if}
                </div>
                <div class="mcr-outline" id="mcr-outline">
                    {$previous_unit = -2}
                    {foreach from = $chapters key = chapter_key item = chapter_title}
                        {$chapter_size = 0}{$chapter_regular = 0}
                        {foreach from = $lessons item = lesson}{if $lesson.chapter == $chapter_key}{$chapter_size = $chapter_size + 1}{if !$lesson.exam}{$chapter_regular = $chapter_regular + 1}{/if}{/if}{/foreach}
                        {if $chapter_size == 0}{continue}{/if}
                        {$chapter_unit = $chapter_units[$chapter_key]|default:-1}
                        {if $chapter_unit != $previous_unit}
                            {if $previous_unit >= 0}</details>{/if}
                            {if $chapter_unit >= 0}
                                <details class="mcr-unit" open>
                                    <summary class="mcr-unit-heading">
                                        <span class="mcr-unit-title" role="heading" aria-level="3">
                                            <span>Học phần {$chapter_unit + 1}</span>
                                            <strong>{$units[$chapter_unit]|escape}</strong>
                                        </span>
                                        <svg class="mcr-chevron" viewBox="0 0 24 24" aria-hidden="true"><path d="m6 9 6 6 6-6" /></svg>
                                    </summary>
                            {/if}
                        {/if}
                        {$previous_unit = $chapter_unit}
                        <details class="mcr-chapter{if $chapter_unit >= 0} mcr-chapter--in-unit{/if}"{if $quiz_course && $chapter_regular == 0} hidden{/if} open>
                            <summary>
                                <span class="mcr-chapter-number">{($chapter_key + 1)|string_format:'%02d'}</span>
                                <span class="mcr-chapter-title">{$chapter_title|escape}</span>
                                <svg class="mcr-chevron" viewBox="0 0 24 24" aria-hidden="true"><path d="m6 9 6 6 6-6" /></svg>
                            </summary>
                            <ol class="mcr-lessons">
                                {foreach from = $lessons item = lesson}
                                    {if $lesson.chapter != $chapter_key}{continue}{/if}
                                    <li class="mcr-lesson-row"{if $quiz_course && $lesson.exam} hidden{/if}>
                                        <div class="mcr-lesson" data-mcr-lesson="{$lesson.number}" data-lesson-type="{$lesson.lesson_type|escape}" data-video="{$lesson.video}" data-access="{$lesson.access}" data-trial="{if $lesson.trial}1{else}0{/if}" data-free-quiz="{if $lesson.free_quiz}1{else}0{/if}" data-title="{$lesson.title|escape}" data-chapter="{$chapter_title|escape}" data-quiz="{if $lesson.open_quiz}1{else}0{/if}" data-quizzes="{count($lesson.quizzes)}">
                                            <span class="mcr-lesson-number">{$lesson.number|string_format:'%02d'}</span>
                                            <span class="mcr-lesson-title">{$lesson.title|escape}</span>
                                            {$visible_tags = []}
                                            {foreach from=$lesson.tags item=tag}
                                                {$tag_key = $tag|trim|lower}
                                                {if $tag_key == 'trọng tâm'}
                                                    {$visible_tags['Trọng tâm'] = 'focus'}
                                                {elseif $tag_key == 'hay ra'}
                                                    {$visible_tags['Hay ra'] = 'frequent'}
                                                {/if}
                                            {/foreach}
                                            {if $lesson.exam || !empty($visible_tags)}
                                                <span class="mcr-lesson-badges">
                                                    {if $lesson.exam}<span class="mcr-lesson-label mcr-lesson-label--type"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 3h12v18H6zM9 8h6M9 12h6M9 16h4" /></svg><span>{$lesson_type_labels[$lesson.lesson_type]|escape}</span></span>{/if}
                                                    {foreach from=$visible_tags key=tag item=tag_style}
                                                        <span class="mcr-lesson-label mcr-lesson-label--{$tag_style}">
                                                            <svg viewBox="0 0 24 24" aria-hidden="true">
                                                                {if $tag_style == 'focus'}<path class="mcr-badge-fill" d="m12 2 3.1 6.3L22 9.4l-5 4.9 1.2 6.9-6.2-3.3-6.2 3.3L7 14.3 2 9.4l6.9-1.1L12 2Z" />
                                                                {else}<path class="mcr-badge-fill" d="M13 2c1 5-3 6-2 10 2-1 3-3 3-5 4 3 6 6 5 10a7 7 0 0 1-14-1c0-3 2-6 4-8-1 4 0 5 1 6-2-6 3-8 3-12Z" />{/if}
                                                            </svg>
                                                            <span>{$tag|escape}</span>
                                                        </span>
                                                    {/foreach}
                                                </span>
                                            {/if}
                                        </div>
                                        <div class="mcr-lesson-actions{if $course_kind == 'knowledge'} mcr-lesson-actions--knowledge{/if}" aria-label="Nội dung {$lesson.title|escape}">
                                            {if !$quiz_course && ($course_kind != 'knowledge' || $lesson.video != '')}<button type="button" class="mcr-lesson-action" data-mcr-open-lesson="{$lesson.number}" data-mcr-open-tab="video">{if $course_kind == 'knowledge'}Học thử{elseif $course_kind == 'exam_solution'}Video chữa đề{else}Video{/if}</button>{/if}
                                            {if !empty($lesson.quizzes) || ($course_kind != 'knowledge' && $lesson.quiz_pending)}<button type="button" class="mcr-lesson-action mcr-lesson-action--quiz" data-mcr-open-lesson="{$lesson.number}" data-mcr-open-tab="quiz">{if $quiz_course}{if $lesson.exam}Thi thử{else}Luyện đề{/if}{else}Bài tập{/if}</button>{/if}
                                        </div>
                                    </li>
                                {/foreach}
                            </ol>
                        </details>
                    {/foreach}
                    {if $previous_unit >= 0}</details>{/if}
                </div>
            </aside>
        </div>
        </div>
        </div>

        <div class="mcr-study-modal" data-mcr-study-modal role="dialog" aria-modal="true" aria-labelledby="mcr-study-title" tabindex="-1" hidden>
            <div class="mcr-study-window">
                <h2 class="mcr-sr-only" id="mcr-study-title" data-mcr-study-title data-mcr-heading></h2>
                <button type="button" class="mcr-study-contribute" data-mcr-contribution-trigger aria-expanded="false" aria-controls="mcr-contribution-panel">Góp ý đáp án, lộ trình hoặc đóng góp đề</button>
                <button type="button" class="mcr-study-close" data-mcr-study-close aria-label="Đóng nội dung bài học"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18"/></svg></button>
            <div class="mcr-main">
                {* Lesson: filled in by classroom.js from the outline *}
                <div class="mcr-view mcr-lesson-view" data-mcr-view="lesson" hidden>
                    {if !$quiz_course}
                    <div class="mcr-panel" id="mcr-panel-video" role="region" aria-label="Video bài học" data-mcr-panel="video"{if $exam_prep} hidden{/if}>
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
                                        {if !empty($text.link_zalo)}<a class="mcr-btn mcr-btn--ghost-light mcr-btn--zalo" href="{$text.link_zalo|escape}" target="_blank" rel="noopener noreferrer">Tư vấn trên Zalo</a>{/if}
                                    </div>
                                    <button type="button" class="mcr-card-link" data-mcr-goto-quiz hidden>Buổi này có bài tập làm thử miễn phí →</button>
                                {/if}
                            </div>
                            <div class="mcr-stage-card" data-mcr-stage="novideo" hidden>
                                <svg class="mcr-card-icon" viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="5" width="18" height="14" rx="2" /><path d="m10 9 5 3-5 3z" /></svg>
                                <h3>Buổi này học trên ClassIn</h3>
                                <p>Video buổi học nằm trong lớp ClassIn của bạn.</p>
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
                                <p>MedUC đang chuẩn bị video cho bài học này.</p>
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
                    </div>

                    <div class="mcr-panel" id="mcr-panel-files" role="region" aria-label="Tài liệu bài học" data-mcr-panel="files" hidden>
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

                    {/if}
                    <div class="mcr-panel" id="mcr-panel-quiz" role="region" aria-label="{if $quiz_course}Luyện đề{else}Bài tập{/if}" data-mcr-panel="quiz"{if !$exam_prep} hidden{/if}>
                        {foreach from = $lessons item = lesson}
                            <div class="mcr-resource" data-mcr-quiz="{$lesson.number}" hidden>
                                {if empty($lesson.quizzes)}
                                    <p class="mcr-empty">{if $lesson.quiz_pending}Bài tập của buổi này đang được cập nhật.{else}Buổi này chưa có bài tập trắc nghiệm.{/if}</p>
                                {else}
                                    {$quiz_total = count($lesson.quizzes)}
                                    {if $quiz_total > 8}
                                        <div class="mcr-quiz-filter" data-mcr-quiz-filter>
                                            <label class="mcr-school-picker" data-mcr-school-picker hidden>
                                                <span class="mcr-school-picker-label">Chọn trường:</span>
                                                <span class="mcr-school-picker-control">
                                                    <svg class="mcr-school-picker-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M3 21h18M5 21V7l7-4 7 4v14M9 21v-4h6v4M8 9h1m6 0h1M8 12h1m6 0h1"/></svg>
                                                    <select aria-label="Chọn trường" data-mcr-quiz-school><option value="">Tất cả trường</option></select>
                                                    <svg class="mcr-school-picker-chevron" viewBox="0 0 24 24" aria-hidden="true"><path d="m6 9 6 6 6-6"/></svg>
                                                </span>
                                            </label>
                                            <span data-mcr-quiz-filter-count role="status" aria-live="polite">{$quiz_total} đề</span>
                                        </div>
                                    {/if}
                                    <div class="mcr-quiz-list">
                                        {foreach from = $lesson.quizzes item = quiz}
                                            {$quiz_info = $course_quizzes.info[$quiz.id]}
                                            <div class="mcr-quiz-card{if !$quiz.open} is-locked{/if}" data-quiz-part="{if $quiz_course && !$lesson.exam}{$quiz@iteration}{/if}" data-quiz-school="{$quiz_info.school|default:''|escape}" data-quiz-reference="{if $quiz_info.read_only}1{else}0{/if}">
                                                <div>
                                                    <p class="mcr-quiz-kicker">{if $quiz_course && !$lesson.exam}Phần{elseif $lesson.exam}Đề thi thử{else}Bài tập trắc nghiệm{/if}{if $quiz_total > 1} {$quiz@iteration}/{$quiz_total}{/if}{if !$licensed && $quiz.free}<span class="mcr-quiz-free">Làm thử miễn phí</span>{/if}</p>
                                                    <h3>{if $quiz_course && !$lesson.exam}Phần {$quiz@iteration} · {$lesson.title|escape}{else}{$quiz_info.name|escape}{/if}</h3>
                                                    {if $quiz_info.school}<p class="mcr-quiz-school">{$quiz_info.school|escape}</p>{/if}
                                                    {if !empty($quiz_info.display_update)}<p class="mcr-quiz-updated">Thời gian cập nhật: <time datetime="{$quiz_info.display_update.iso_date|escape}">{$quiz_info.display_update.date|escape}</time></p>{/if}
                                                    <p>{if !$quiz.ready}Đang biên soạn{else}{$quiz_info.count} câu{/if}{if $quiz_info.minutes > 0 && !$quiz_info.read_only} · {$quiz_info.minutes} phút{/if} · {if $quiz.open}{if $quiz_info.read_only}Xem hình, đáp án và giải thích; không cần nộp bài.{elseif $quiz_course && !$lesson.exam}Làm từng câu, xem đáp án và lời giải ngay.{else}Nộp bài để xem điểm và lời giải.{/if}{else}{if $quiz_course}Đăng ký môn để mở các đề trả phí.{else}Đăng ký khoá học để làm bài tập này.{/if}{/if}</p>
                                                </div>
                                                <div class="mcr-quiz-actions">
                                                {if !$quiz_info.read_only}<button type="button" class="mcr-btn mcr-btn--ghost" data-mcr-quiz-ready="{if $quiz.ready}1{else}0{/if}" data-mcr-quiz-history="{$quiz.id}" data-mcr-quiz-free="{if $quiz.free}1{else}0{/if}" {if !$quiz.open}hidden{/if} data-lesson="{$lesson.number}" data-lesson-title="{$lesson.title|escape}" data-lesson-code="{$lesson.code|escape}">Lịch sử</button>{/if}
                                                <button type="button" class="mcr-btn mcr-btn--primary" data-mcr-quiz-ready="{if $quiz.ready}1{else}0{/if}" data-mcr-quiz-start="{$quiz.id}" data-mcr-quiz-free="{if $quiz.free}1{else}0{/if}" {if !$quiz.open}hidden{/if} data-lesson="{$lesson.number}" data-lesson-title="{$lesson.title|escape}" data-lesson-code="{$lesson.code|escape}">{if $quiz_info.read_only}Xem đáp án{else}Làm bài{/if}</button>
                                                <a data-mcr-quiz-enroll {if $quiz.open || !$quiz.ready}hidden{/if} class="mcr-btn mcr-btn--primary mcr-quiz-unlock" {if $in_cart}href="/order/info"{else}href="javascript:;" nh-btn-action="add-cart" nh-redirect="/order/info"{/if}>
                                                        <svg class="mcr-lock" viewBox="0 0 24 24" aria-hidden="true"><rect x="5" y="11" width="14" height="10" rx="2.5"/><path d="M8 11V7a4 4 0 0 1 8 0v4M12 15v2"/></svg>
                                                        <span class="mcr-quiz-unlock-copy"><span>{if $quiz_course}Mở khoá tất cả bài tập{else}Đăng ký khoá học{/if}</span><small>· {$price_text}</small></span>
                                                    </a>
                                                </div>
                                            </div>
                                        {/foreach}
                                    </div>
                                    {if $quiz_total > 8}<nav class="mcr-quiz-pagination" aria-label="Trang danh sách đề" data-mcr-quiz-pagination></nav>{/if}
                                {/if}
                            </div>
                        {/foreach}
                        {* classroom-quiz.js builds the quiz here; the lesson's card above hides while it runs. *}
                        <div class="mcq" data-mcr-quiz-player hidden></div>
                    </div>

                </div>
            </div>
            <p class="mcr-quiz-disclaimer" data-mcr-policy role="note">Bộ đề được đội ngũ ThS, BSNT của MedUC tổng hợp, rà soát và giải đáp, có hỗ trợ một phần của AI. Nội dung có thể còn sai sót; MedUC trân trọng mọi góp ý về đề, đáp án và lộ trình học.</p>
            </div>
        </div>
                        <div class="mcr-contribution-modal" id="mcr-contribution-panel" data-mcr-contribution role="dialog" aria-modal="true" aria-labelledby="mcr-contribution-title" tabindex="-1" hidden>
                            <div class="mcr-contribution">
                                <div class="mcr-contribution-heading"><h2 id="mcr-contribution-title">Góp ý và đóng góp</h2><button type="button" class="mcr-contribution-close" data-mcr-contribution-close aria-label="Đóng góp ý"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18"/></svg></button></div>
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
                            </div>
                        </div>
        {if $quiz_course && !$licensed}
        <template data-mcr-quiz-purchase><a class="mcr-btn mcr-btn--primary" {if $in_cart}href="/order/info"{else}href="javascript:;" nh-btn-action="add-cart" nh-redirect="/order/info"{/if}>Mở phần 2 toàn môn · {$price_text}</a></template>
        {/if}
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
