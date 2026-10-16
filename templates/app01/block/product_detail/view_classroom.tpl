{strip}
{* Course page as a classroom: the course outline on the left, and on the right either the course introduction
   (video, price, sign-up) or the selected lesson with its Video / Tài liệu / Bài tập / Phản hồi học viên tabs.
   The page opens on the introduction; ?bai=N opens lesson N (classroom.js keeps the address in step).
   - Lessons come from the course's "Danh sách tiết học". A lesson marked "Học thử" is open to everyone; only lessons
     with a YouTube ID have a video here (students study the paid lessons on ClassIn). Students of the course see every
     lesson: an old class room with their code, or an enrollment (paid order or added by the admin), see
     MemberHelper::getCourseAccess.
   - A lesson may have several quizzes (App\Lib\LessonQuizzes), each either free to try or for students only. Quizzes
     run inside the "Bài tập" tab (classroom-quiz.js) and results are saved to /quizs-answer/add as before; a locked quiz
     shows its name and size with the sign-up button, and its questions never reach the page.
   - Sign-up uses the site's cart (nh-btn-action="add-cart"); PDF files keep using custom.js.
   - The introduction has its own tabs (Giới thiệu, Giảng viên, Q&A, Phản hồi) over one long column, and a sign-up column
     that stays in place. Teachers: the homepage faculty cards (block "gvrail") linking to this course, and the course's
     "Thông tin giảng viên". The FAQ, questions, ratings and related-course blocks below this one on the page are moved
     into the introduction by classroom.js (see the data-mcr-slot elements); without JavaScript they stay below.
   - Student feedback: videos of block "fbvideos" whose "Mô tả ngắn" is this course's address, else the first videos;
     text reviews of block "hvreview".
   Text: the block's "Dữ liệu mở rộng": link_zalo, loi_moi (line above the sign-up button), ghi_chu_bai_tap (quiz note). *}
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
{* Exam-prep course (Khóa học > Khóa luyện thi, category 125): one lesson holding the subject's exams. *}
{$exam_prep = !empty($product.main_category_id) && $product.main_category_id == 125}
{$first_open = 0}
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
    {if $video != '' && $open && $first_open == 0}{$first_open = $number}{/if}
    {$access = 'locked'}
    {if $licensed}{$access = 'open'}{elseif $trial}{$access = 'trial'}{/if}
    {$review = !empty($item.review_vi) && $item.review_vi == 'y'}
    {$code = ''}
    {if !empty($item.code)}{$code = $item.code}{/if}

    {$lessons[] = ['number' => $number, 'title' => $item_title, 'chapter' => $chapter_index, 'video' => $video, 'access' => $access, 'open' => $open, 'files' => $files, 'quizzes' => $quizzes, 'open_quiz' => $open_quiz, 'free_quiz' => $free_quiz, 'quiz_pending' => count($lesson_quizzes) > count($quizzes), 'review' => $review, 'code' => $code]}
{/foreach}
{$lesson_count = count($lessons)}

{* Course facts *}
{$attributes = []}
{if !empty($product.attributes)}{$attributes = $product.attributes}{/if}
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

{* Student feedback for the "Phản hồi học viên" tab *}
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
{$reviews = []}
{$review_items = $this->Block->getSliderItems('hvreview')}
{foreach from = $review_items item = review}
    {if !empty($review.description_short)}{$reviews[] = $review}{/if}
{/foreach}

{* Teachers of this course *}
{$teachers = []}
{if !empty($attributes.thongtingiangvien.value)}
    {$teacher_articles = $this->Article->getArticles(['filter' => ['ids' => json_decode($attributes.thongtingiangvien.value, true)], 'get_attributes' => true])}
    {foreach from = $teacher_articles item = article}
        {if empty($article.name)}{continue}{/if}
        {$teacher_name = $article.name|trim}
        {$teacher_text = $article.description|default:''|strip_tags|trim}
        {$teacher_photo = ''}
        {if !empty($article.image_avatar)}{$teacher_photo = "{CDN_URL}{$article.image_avatar}"}{/if}
        {$teachers[] = ['name' => $teacher_name, 'subject' => 'Giảng viên', 'description' => $teacher_text, 'photo' => $teacher_photo, 'poster' => false]}
    {/foreach}
{/if}
{$faculty_items = $this->Block->getSliderItems('gvrail')}
{foreach from = $faculty_items item = person}
    {if empty($person.name) || empty($person.url) || $person.url|trim != $course_path}{continue}{/if}
    {$full_name = $person.name|trim}
    {$teacher_name = $full_name|regex_replace:'/\s*\([^()]*\)\s*$/u':''|regex_replace:'/\s+/u':' '}
    {$teacher_subject = 'Giảng viên MedUC'}
    {if preg_match('/\([^()]*\)\s*$/u', $full_name)}
        {$teacher_subject = $full_name|regex_replace:'/^.*\(\s*([^()]*?)\s*\)\s*$/us':'$1'|regex_replace:'/^Dạy\s+/iu':''}
    {/if}
    {$teacher_text = $person.description|default:''|regex_replace:'/^[\s\-\/]+/u':''|regex_replace:'/\s*[\r\n]+[\s\-\/]*/u':' · '|regex_replace:'/[\s·]+$/u':''}
    {$teacher_photo = ''}
    {if !empty($person.image)}
        {if $person.image_source == 'cdn'}{$teacher_photo = "{CDN_URL}{$this->Utilities->getThumbs($person.image, 720)}"}{else}{$teacher_photo = $person.image}{/if}
    {/if}
    {$teachers[] = ['name' => $teacher_name, 'subject' => $teacher_subject, 'description' => $teacher_text, 'photo' => $teacher_photo, 'poster' => true]}
{/foreach}

{* The feedback list appears twice: in the introduction and in the lesson's "Phản hồi học viên" tab. *}
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
    {if !empty($reviews)}
        <div class="mcr-quotes">
            {foreach from = $reviews item = review}
                {if $review@iteration > 4}{break}{/if}
                <blockquote class="mcr-quote">
                    <p>“{$review.description_short|escape}”</p>
                    <footer>{if !empty($review.name)}<strong>{$review.name|escape}</strong>{/if}{if !empty($review.description)} · {$review.description|escape}{/if}</footer>
                </blockquote>
            {/foreach}
        </div>
    {/if}
    <a class="mcr-feedback-all" href="/phan-hoi-hoc-vien">Xem tất cả phản hồi của học viên <span aria-hidden="true">→</span></a>
{/capture}

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/classroom.css?v=20261016-10" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/classroom.js?v=20261016-6" defer></script>
{if $any_open_quiz}<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/classroom-quiz.js?v=20261016-4" defer></script>{/if}

<section class="mcr" data-mcr data-mcr-licensed="{if $licensed}1{else}0{/if}" data-mcr-count="{$lesson_count}" data-mcr-product="{$product.id}" data-mcr-exam-prep="{if $exam_prep}1{else}0{/if}" data-mcr-member="{if !empty($member_info.id)}{$member_info.id}{/if}" data-mcr-member-code="{$code_member}" data-mcr-class-room="{$class_room_id}" nh-product-detail nh-product="{$product.id}" nh-product-item-id="{if !empty($first_item.id)}{$first_item.id}{/if}" nh-product-attribute-special="{if !empty($product.attributes_item_special)}{htmlentities($product.attributes_item_special|@json_encode)}{/if}">
    <div class="mcr-shell">
        <nav class="mcr-breadcrumb" aria-label="Đường dẫn">
            <a href="/">Trang chủ</a><span aria-hidden="true">›</span>{if $exam_prep}<a href="/khoa-luyen-thi">Luyện thi</a>{else}<a href="/khoa-hoc">Khoá học</a>{/if}<span aria-hidden="true">›</span><span aria-current="page">{$product.name|escape}</span>
        </nav>
        {* The course name is the page's main heading for search engines and screen readers; the outline and the
           introduction already show the course, so it is not repeated on screen. *}
        <h1 class="mcr-sr-only">{$product.name|escape}</h1>

        <div class="mcr-layout">
            {* Course outline *}
            <aside class="mcr-sidebar" aria-label="Đề cương khoá học">
                <div class="mcr-outline-head">
                    <h2>Đề cương khoá học</h2>
                    <span>{count($chapters)} chương</span>
                    <button type="button" class="mcr-search-toggle" aria-expanded="false" aria-controls="mcr-search" aria-label="Tìm bài học">
                        <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="7" /><path d="m20 20-3.5-3.5" /></svg>
                    </button>
                </div>
                <div class="mcr-search" id="mcr-search" hidden>
                    <input type="search" placeholder="Tìm chương hoặc bài học" aria-label="Tìm chương hoặc bài học" data-mcr-search>
                </div>
                <a class="mcr-intro-link is-active" href="{$course_path|escape}" data-mcr-intro aria-current="page">
                    <span class="mcr-intro-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9" /><path d="M12 11v6M12 7.5v.5" /></svg></span>
                    <span><strong>Giới thiệu khoá học</strong><small>Học phí, đăng ký và học thử</small></span>
                </a>
                <div class="mcr-outline">
                    {foreach from = $chapters key = chapter_key item = chapter_title}
                        {$chapter_size = 0}
                        {foreach from = $lessons item = lesson}{if $lesson.chapter == $chapter_key}{$chapter_size = $chapter_size + 1}{/if}{/foreach}
                        {if $chapter_size == 0}{continue}{/if}
                        <details class="mcr-chapter" {if $chapter_key == 0}open{/if}>
                            <summary>
                                <span class="mcr-chapter-number">{($chapter_key + 1)|string_format:'%02d'}</span>
                                <span class="mcr-chapter-title">{$chapter_title|escape}<small>{$chapter_size} bài</small></span>
                                <svg class="mcr-chevron" viewBox="0 0 24 24" aria-hidden="true"><path d="m6 9 6 6 6-6" /></svg>
                            </summary>
                            <ol class="mcr-lessons">
                                {foreach from = $lessons item = lesson}
                                    {if $lesson.chapter != $chapter_key}{continue}{/if}
                                    <li>
                                        <a class="mcr-lesson" href="?bai={$lesson.number}" data-mcr-lesson="{$lesson.number}" data-video="{$lesson.video}" data-access="{$lesson.access}" data-title="{$lesson.title|escape}" data-chapter="{$chapter_title|escape}" data-quiz="{if $lesson.open_quiz}1{else}0{/if}" data-quizzes="{count($lesson.quizzes)}">
                                            <span class="mcr-lesson-number">{$lesson.number|string_format:'%02d'}</span>
                                            <span class="mcr-lesson-title">{$lesson.title|escape}</span>
                                            {if $lesson.access == 'trial' && $lesson.video != ''}
                                                <span class="mcr-tag">Học thử</span>
                                            {elseif !$licensed && $lesson.free_quiz}
                                                <span class="mcr-tag mcr-tag--quiz">Bài tập</span>
                                            {elseif !$lesson.open || ($lesson.video == '' && !$licensed)}
                                                <svg class="mcr-lock" viewBox="0 0 24 24" aria-label="Cần đăng ký"><rect x="5" y="10.5" width="14" height="10" rx="2" /><path d="M8 10.5V7.5a4 4 0 0 1 8 0v3" /></svg>
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
                {* Introduction: what a visitor sees first *}
                <div class="mcr-view mcr-intro" data-mcr-view="intro">
                    <div class="mcr-intro-main">
                        <nav class="mcr-anchors" aria-label="Các phần giới thiệu khoá học">
                            <a href="#mcr-gioi-thieu" data-mcr-anchor>Giới thiệu</a>
                            {if !empty($teachers)}<a href="#mcr-giang-vien" data-mcr-anchor>Giảng viên</a>{/if}
                            <a href="#mcr-qa" data-mcr-anchor>Q&amp;A</a>
                            <a href="#mcr-phan-hoi" data-mcr-anchor>Phản hồi</a>
                        </nav>

                        {* The video sits apart from the description so that, on narrow screens, the sign-up card can come right after it. *}
                        <div class="mcr-intro-hero" id="mcr-gioi-thieu">
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
                                <h2 class="mcr-section-title">Về khoá học</h2>
                                <div class="mcr-richtext">
                                    {if !empty($attributes.motangan.value)}<div class="mcr-lead">{$attributes.motangan.value}</div>{/if}
                                    {if !empty($attributes.motakhoahoc.value)}{$attributes.motakhoahoc.value}{/if}
                                </div>
                            {/if}
                        </section>

                        {if !empty($teachers)}
                            <section class="mcr-section" id="mcr-giang-vien" aria-labelledby="mcr-teachers-title">
                                <h2 class="mcr-section-title" id="mcr-teachers-title">Giảng viên</h2>
                                <div class="mcr-teachers">
                                    {foreach from = $teachers item = teacher}
                                        <article class="mcr-teacher-card">
                                            {if $teacher.photo != ''}<img class="{if $teacher.poster}is-poster{/if}" src="{$teacher.photo|escape}" alt="Chân dung {$teacher.name|escape}" loading="lazy" decoding="async" />{/if}
                                            <div>
                                                <span class="mcr-teacher-subject">{$teacher.subject|escape}</span>
                                                <h3>{$teacher.name|escape}</h3>
                                                {if $teacher.description != ''}<p>{$teacher.description|escape}</p>{/if}
                                            </div>
                                        </article>
                                    {/foreach}
                                </div>
                                <a class="mcr-section-link" href="/doi-ngu-giang-vien">Xem hồ sơ đội ngũ giảng viên <span aria-hidden="true">→</span></a>
                            </section>
                        {/if}

                        {* Filled by classroom.js with the FAQ and questions blocks placed below this one on the page. *}
                        <section class="mcr-section mcr-section--slots" id="mcr-qa" aria-label="Hỏi đáp">
                            <div class="mcr-slot" data-mcr-slot="6a5tyhf"></div>
                            <div class="mcr-slot" data-mcr-slot="zdi3rma"></div>
                        </section>

                        <section class="mcr-section" id="mcr-phan-hoi" aria-label="Phản hồi">
                            <div class="mcr-slot" data-mcr-slot="5y31vx8"></div>
                            <div class="mcr-feedback">{$smarty.capture.mcr_feedback}</div>
                        </section>

                        <div class="mcr-slot mcr-slot--related" data-mcr-slot="sw780fy"></div>
                    </div>

                    <aside class="mcr-intro-side" aria-label="Đăng ký khoá học">
                        <div class="mcr-buy">
                            {if !$licensed}
                                <p class="mcr-price"><strong>{$price_text}</strong>{if $old_price_text != ''}<s>{$old_price_text}</s><span class="mcr-discount">−{$discount}%</span>{/if}</p>
                                {if !empty($text.loi_moi)}<p class="mcr-buy-note">{$text.loi_moi|escape}</p>{/if}
                                <a class="mcr-btn mcr-btn--primary mcr-btn--block" {if $in_cart}href="/order/info"{else}href="javascript:;" nh-btn-action="add-cart" nh-redirect="/order/info"{/if}>Đăng ký học</a>
                                {if $first_open > 0}
                                    <a class="mcr-btn mcr-btn--secondary mcr-btn--block" href="?bai={$first_open}" data-mcr-start="{$first_open}"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M8 5.5v13l11-6.5z" /></svg><span data-mcr-start-label>Học thử miễn phí</span></a>
                                {/if}
                                {if !empty($text.link_zalo)}
                                    <a class="mcr-btn mcr-btn--ghost mcr-btn--block" href="{$text.link_zalo|escape}" target="_blank" rel="noopener noreferrer">Tư vấn trên Zalo</a>
                                {/if}
                            {else}
                                <p class="mcr-owned">Bạn đã sở hữu khoá học này</p>
                                {if $first_open > 0}
                                    <a class="mcr-btn mcr-btn--primary mcr-btn--block" href="?bai={$first_open}" data-mcr-start="{$first_open}"><span data-mcr-start-label>Vào học</span></a>
                                {/if}
                                <a class="mcr-btn mcr-btn--ghost mcr-btn--block" href="/member/classroom">Lớp học của tôi</a>
                            {/if}
                            <dl class="mcr-specs">
                                {if !empty($attributes.thoiluong.value)}<div><dt>Thời lượng</dt><dd>{$attributes.thoiluong.value|strip_tags|escape}</dd></div>{/if}
                                {if $exam_prep}
                                    <div><dt>Đề thi</dt><dd>{$quiz_count} đề</dd></div>
                                {else}
                                    <div><dt>Bài học</dt><dd>{if !empty($attributes.soluongbaihoc.value)}{$attributes.soluongbaihoc.value|strip_tags|escape}{else}{$lesson_count} bài{/if} · {count($chapters)} chương</dd></div>
                                {/if}
                                {if !empty($attributes.soluongbaitap.value)}<div><dt>Bài tập</dt><dd>{$attributes.soluongbaitap.value|strip_tags|escape}</dd></div>{/if}
                                {if !$licensed && ($trial_videos > 0 || $open_quizzes > 0)}<div><dt>Học thử</dt><dd>{if $trial_videos > 0}{$trial_videos} buổi video{/if}{if $trial_videos > 0 && $open_quizzes > 0} · {/if}{if $open_quizzes > 0}{$open_quizzes} {if $exam_prep}đề miễn phí{else}bài tập{/if}{/if}</dd></div>{/if}
                                {if !empty($course_files)}<div><dt>Tài liệu</dt><dd>{count($course_files)} tệp</dd></div>{/if}
                                {if !empty($product.rating_number) && $product.rating_number > 0}<div><dt>Đánh giá</dt><dd>★ {$product.rating|string_format:'%.1f'} ({$product.rating_number})</dd></div>{/if}
                            </dl>
                        </div>
                    </aside>
                </div>

                {* Lesson: filled in by classroom.js from the outline *}
                <div class="mcr-view mcr-lesson-view" data-mcr-view="lesson" hidden>
                    <div class="mcr-lesson-head">
                        <div>
                            <p class="mcr-location" data-mcr-location></p>
                            <h2 class="mcr-lesson-heading" data-mcr-heading></h2>
                        </div>
                        <span class="mcr-access" data-mcr-access></span>
                    </div>
                    <div class="mcr-toolbar">
                        <div class="mcr-tabs" role="tablist" aria-label="Nội dung bài học">
                            <button type="button" role="tab" id="mcr-tab-video" aria-controls="mcr-panel-video" aria-selected="true" data-mcr-tab="video">Video</button>
                            <button type="button" role="tab" id="mcr-tab-files" aria-controls="mcr-panel-files" aria-selected="false" tabindex="-1" data-mcr-tab="files">Tài liệu</button>
                            <button type="button" role="tab" id="mcr-tab-quiz" aria-controls="mcr-panel-quiz" aria-selected="false" tabindex="-1" data-mcr-tab="quiz">Bài tập</button>
                            <button type="button" role="tab" id="mcr-tab-feedback" aria-controls="mcr-panel-feedback" aria-selected="false" tabindex="-1" data-mcr-tab="feedback">Phản hồi học viên</button>
                        </div>
                        {if !$licensed}
                            <div class="mcr-toolbar-buy">
                                <span class="mcr-toolbar-price"><strong>{$price_text}</strong>{if $old_price_text != ''}<s>{$old_price_text}</s>{/if}</span>
                                <a class="mcr-btn mcr-btn--primary" {if $in_cart}href="/order/info"{else}href="javascript:;" nh-btn-action="add-cart" nh-redirect="/order/info"{/if}>Đăng ký học</a>
                            </div>
                        {else}
                            <span class="mcr-toolbar-progress" data-mcr-progress></span>
                        {/if}
                    </div>

                    <div class="mcr-panel" id="mcr-panel-video" role="tabpanel" aria-labelledby="mcr-tab-video" data-mcr-panel="video">
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
                                        <a class="mcr-btn mcr-btn--primary" {if $in_cart}href="/order/info"{else}href="javascript:;" nh-btn-action="add-cart" nh-redirect="/order/info"{/if}>Đăng ký học</a>
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
                                <p>MedUC đang chuẩn bị video chữa đề cho phần này. Trong lúc chờ, bạn làm đề ngay ở tab Bài tập: nộp bài là có điểm và lời giải chi tiết.</p>
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

                    <div class="mcr-panel" id="mcr-panel-quiz" role="tabpanel" aria-labelledby="mcr-tab-quiz" data-mcr-panel="quiz" hidden>
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
                                                    <p class="mcr-quiz-kicker">{if $lesson.review}Đề tổng ôn{else}Bài tập trắc nghiệm{/if}{if $quiz_total > 1} {$quiz@iteration}/{$quiz_total}{/if}{if !$licensed && $quiz.free}<span class="mcr-quiz-free">Làm thử miễn phí</span>{/if}</p>
                                                    <h3>{$quiz_info.name|escape}</h3>
                                                    <p>{$quiz_info.count} câu{if $quiz_info.minutes > 0} · {$quiz_info.minutes} phút{/if} · {if $quiz.open}Nộp bài là có điểm và lời giải chi tiết.{else}Dành cho học viên đã đăng ký khoá học.{/if}</p>
                                                </div>
                                                {if $quiz.open}
                                                    <button type="button" class="mcr-btn mcr-btn--primary" data-mcr-quiz-start="{$quiz.id}" data-lesson="{$lesson.number}" data-lesson-title="{$lesson.title|escape}" data-lesson-code="{$lesson.code|escape}">Bắt đầu làm bài</button>
                                                {else}
                                                    <a class="mcr-btn mcr-btn--ghost" {if $in_cart}href="/order/info"{else}href="javascript:;" nh-btn-action="add-cart" nh-redirect="/order/info"{/if}>
                                                        <svg class="mcr-lock" viewBox="0 0 24 24" aria-hidden="true"><rect x="5" y="10.5" width="14" height="10" rx="2" /><path d="M8 10.5V7.5a4 4 0 0 1 8 0v3" /></svg>
                                                        Đăng ký để làm
                                                    </a>
                                                {/if}
                                            </div>
                                        {/foreach}
                                    </div>
                                {/if}
                            </div>
                        {/foreach}
                        {* classroom-quiz.js builds the quiz here; the lesson's card above hides while it runs. *}
                        <div class="mcq" data-mcr-quiz-player hidden></div>
                        {if !empty($text.ghi_chu_bai_tap)}<p class="mcr-quiz-disclaimer" data-mcr-quiz-note hidden>{$text.ghi_chu_bai_tap|escape}</p>{/if}
                        <a class="mcr-quiz-rank" href="/class-rank?khoa={$product.id}">Bảng xếp hạng và chỉ số tiến bộ của bạn <span aria-hidden="true">→</span></a>
                    </div>

                    <div class="mcr-panel" id="mcr-panel-feedback" role="tabpanel" aria-labelledby="mcr-tab-feedback" data-mcr-panel="feedback" hidden>
                        {$smarty.capture.mcr_feedback}
                    </div>
                </div>
            </div>
        </div>
    </div>

    {if !$licensed}
        {* Phones: the sign-up bar takes the place of the site's bottom action bar on this page. *}
        <div class="mcr-buybar">
            <span class="mcr-toolbar-price"><strong>{$price_text}</strong>{if $old_price_text != ''}<s>{$old_price_text}</s>{/if}</span>
            <a class="mcr-btn mcr-btn--primary" {if $in_cart}href="/order/info"{else}href="javascript:;" nh-btn-action="add-cart" nh-redirect="/order/info"{/if}>Đăng ký học</a>
        </div>
    {/if}

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
