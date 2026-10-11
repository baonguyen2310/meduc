<section class="mx-library" data-course-exams data-course="{$course_exam_id}" data-base="{ADMIN_PATH}" data-download="{if !empty($course_exam_download)}1{else}0{/if}">
    <header class="mx-library-head">
        <div><span class="mx-eyebrow">MEDUC · {if !empty($course_is_exam_prep)}KHOÁ LUYỆN THI{else}NỘI DUNG KHOÁ HỌC{/if}</span>
            <h2>{if !empty($course_is_exam_prep)}Đề tổng ôn{else}Danh sách bài học{/if}</h2>
            <p>{if !empty($course_is_exam_prep)}Kho đề nội bộ dành cho quản trị viên và giáo viên phụ trách.{else}Chọn bài có bài tập để xem đề hoặc làm thử.{/if}</p>
        </div>
        <span class="mx-count">{$course_lessons|count} mục</span>
    </header>
    {if !empty($course_lessons)}
        <div class="mx-tools"><label class="mx-search"><i class="la la-search" aria-hidden="true"></i><input type="search" data-exam-search placeholder="Tìm tên đề{if !empty($course_is_exam_prep)}, trường, năm…{else}…{/if}" aria-label="Tìm trong danh sách bài"></label><span data-exam-visible></span></div>
        <div class="mx-lessons">
            {foreach from=$course_lessons item=lesson}
                {if $lesson.chapter}
                    <h3 class="mx-chapter">{$lesson.name|escape}</h3>
                {else}
                    <article class="mx-lesson" data-exam-row>
                        <span class="mx-number">{$lesson.position|string_format:'%02d'}</span>
                        <div class="mx-lesson-content">
                            {if !empty($lesson.quiz_id)}<button type="button" class="mx-title" data-exam-open="{$lesson.quiz_id}">{$lesson.name|escape}</button>{else}<span class="mx-title">{$lesson.name|escape}</span>{/if}
                            {if !empty($course_is_exam_prep)}
                                <div class="mx-meta">
                                    <span class="mx-year">{if !empty($lesson.metadata.year_in_title)}{$lesson.metadata.year_in_title|escape}{else}Không ghi năm{/if}</span>
                                    {if !empty($lesson.metadata.school_name)}<span>{$lesson.metadata.school_name|escape}</span>{/if}
                                    {if isset($lesson.metadata.question_count)}<span>{$lesson.metadata.question_count} câu</span>{/if}
                                </div>
                                {if !empty($lesson.metadata.source_category_name)}<div class="mx-category">{$lesson.metadata.source_category_name|escape}</div>{/if}
                            {elseif $lesson.review}<div class="mx-meta"><span>Đề tổng ôn</span></div>{/if}
                        </div>
                        {if !empty($lesson.quiz_id)}
                            <div class="mx-actions">
                                <button type="button" class="mx-open" data-exam-open="{$lesson.quiz_id}" aria-label="Xem {$lesson.name|escape}">Xem đề <span aria-hidden="true">↗</span></button>
                                {if !empty($course_exam_download)}<button type="button" class="mx-word" data-exam-word="{$lesson.quiz_id}" title="Tải đề và đáp án dạng Word"><i class="la la-download" aria-hidden="true"></i> Word</button>{/if}
                            </div>
                        {else}<span class="mx-muted">Chưa có bài tập</span>{/if}
                    </article>
                {/if}
            {/foreach}
        </div>
        <p class="mx-empty" data-exam-empty hidden>Không có đề phù hợp với từ khoá này.</p>
    {else}<p class="mx-empty">Khóa học chưa có bài.</p>{/if}
    <p class="mx-notice" data-exam-notice role="status" hidden></p>
    <dialog class="mx-dialog" aria-labelledby="mx-dialog-title">
        <header class="mx-dialog-head"><div><span class="mx-eyebrow">MEDUC · XEM ĐỀ & LÀM THỬ</span><h2 id="mx-dialog-title">Đang tải đề…</h2><p data-exam-summary></p></div><button type="button" class="mx-close" data-exam-close aria-label="Đóng">×</button></header>
        <div class="mx-modebar"><div class="mx-tabs" role="tablist" aria-label="Chế độ xem đề"><button type="button" role="tab" data-exam-mode="view" aria-selected="true">Xem đề</button><button type="button" role="tab" data-exam-mode="practice" aria-selected="false">Làm thử</button></div><span class="mx-muted" data-exam-mode-note>Xem câu hỏi, đáp án và giải thích</span></div>
        <div class="mx-dialog-main"><aside class="mx-question-nav" aria-label="Đi đến câu hỏi"><h3>Câu hỏi</h3><div data-exam-nav></div><p data-exam-progress></p></aside><div class="mx-question-scroll" data-exam-scroll><div data-exam-questions class="mx-questions"></div></div></div>
        <footer class="mx-dialog-foot"><div data-exam-result role="status">Chọn “Làm thử” để tự kiểm tra kiến thức.</div><div class="mx-foot-actions"><button type="button" class="mx-word" data-exam-modal-word {if empty($course_exam_download)}hidden{/if}><i class="la la-download" aria-hidden="true"></i> Tải Word</button><button type="button" class="mx-primary" data-exam-grade hidden>Chấm điểm</button></div></footer>
    </dialog>
</section>
