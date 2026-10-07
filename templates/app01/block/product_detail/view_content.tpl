{assign var = product value = []}
{if !empty($data_block.data)}
	{assign var = product value = $data_block.data}
{/if}

{assign var = first_item value = []}
{if !empty($product.items[0])}
	{assign var = first_item value = $product.items[0]}
{/if}

{assign var = all_images value = []}
{if !empty($product.all_images)}
	{assign var = all_images value = $product.all_images}
{/if}

{if !empty($product)}
    {assign var = licensed value = false}
    {assign member_info value = $this->Member->getMemberInfo()}
    {if !empty($member_info.code)}
        {assign var = code_member value = $member_info.code}
        {assign var = listClassRoom value = $this->Member->getListClassRoomByCustomerId($code_member)}
        {assign var = classRoomCurrent value = ""}
        
        {foreach from = $listClassRoom item = classRoom}
            {if $classRoom.product_id == $product.id}
                {assign var = licensed value = true}
                {assign var = classRoomCurrent value = $classRoom.id}
                {break}
            {/if}
        {/foreach}
    {/if}
    
    <ul class="nav course-tab mt--40" role="tablist">
        <li class="nav-item text-center">
            <a class="nav-link active" nh-to-anchor="mota" href="javascript:;">Mô tả</a>
        </li>
        <li class="nav-item text-center {if $licensed == true}active{/if}">
            <a nh-to-anchor="noidung" class="nav-link" href="javascript:;">
                Nội dung
            </a>
        </li>
        {*<li class="nav-item text-center"><a nh-to-anchor="giangvien" class="nav-link" href="javascript:;">Giảng viên</a></li>*}
        <li class="nav-item text-center"><a nh-to-anchor="cauhoithuonggap" class="nav-link" href="javascript:;">Câu hỏi thường gặp</a></li>
        <li class="nav-item text-center"><a nh-to-anchor="rating" class="nav-link" href="javascript:;">Đánh giá</a></li>
        <li class="nav-item text-center"><a nh-to-anchor="comment" class="nav-link" href="javascript:;">Đặt câu hỏi</a></li>
    </ul>
    
    {if !empty($product.attributes.motakhoahoc.value)}
        <div class="course-details-card mt--40" nh-anchor="mota">
            <div class="title-section-2">
                <span>Mô tả khóa học</span>
            </div>
            {*<div class="content-format box-content-detail">
                {$product.attributes.motakhoahoc.value}
            </div>*}
            <div class="show-more mt-30 js-show-more">
                <div class="show-more__content">
                    {$product.attributes.motakhoahoc.value}
                </div>

                <button class="show-more__button edu-btn edu-btn-blue text-center mt-10">Xem thêm</button>
            </div>
        </div>
    {/if}
    
    <div class="course-details-card mt--40" nh-anchor="noidung" data-mcl-licensed="{if $licensed}1{else}0{/if}">
        <div class="title-section-2">
            <span>Nội dung khóa học</span>
        </div>
        {assign var = danhsachtiethoc value = $product.attributes.danhsachtiethoc.value|json_decode:1}
        <div class="accordion-list">
            {foreach from = $danhsachtiethoc key = key item = item}
                
                {if !empty($item.chapter_vi) && ($item.chapter_vi == "y")}
                    <div class="accordion-chapter">
            	        <h2>
            	            {if !empty($item.name_vi)}
                			    {$item.name_vi}
                			{/if}
            	        </h2>
                    </div>
    	        {else}
	            <div class="accordion-item" data-mcl-trial="{if !empty($item.trial_vi) && $item.trial_vi == 'y'}1{else}0{/if}" data-mcl-has-video="{if !empty($item.youtube_id_vi)}1{else}0{/if}" data-mcl-has-quiz="{if !empty($item.quiz_id_vi)}1{else}0{/if}">
    	                <div class="inner-head">
    	                    <h3>
    	                        <i class="iconsax isax-video isax-lg"></i>
                                <span>
                                    {if !empty($item.name_vi)}
                        			    {$item.name_vi}
                        			{/if}
                                </span>
                            </h3>
                            
                            {*if !empty($item.quiz_id_vi) && ($item.quiz_id_vi|count_characters > 0)}
                                {assign quizs_answer_pass value = $this->Utilities->quizsAnswerPass({$member_info.id}, {$product.id}, {$item.quiz_id_vi}, 50)}
                            {else}
                                {assign quizs_answer_pass value = []}
                            {/if*}
                            
                            <div class="inner-file">
                                {if !empty($item.youtube_id_vi)}
                                    {if ($item.trial_vi == "y") && $licensed==false}
                        			    <a href="https://www.youtube.com/watch?v={$item.youtube_id_vi}" class="glightbox-video-course" btn-trial>
                                            Học thử
                                        </a>
                                    {else if ($licensed==true)}
                        			    {*<a href="https://www.youtube.com/watch?v={$item.youtube_id_vi}" class="glightbox-video-course {if ($quizs_answer_pass|@count < 1) && ($item.trial_vi != "y")}d-none{/if}">*}
                        			    <a href="https://www.youtube.com/watch?v={$item.youtube_id_vi}" class="glightbox-video-course">
                                            Vào Học
                                        </a>
                                    {else}
                                        <i class="iconsax isax-lock isax-lg color-main"></i>
                                    {/if}
                                {/if}
                            </div>
                            
                            {if !empty($item.quiz_id_vi)}
    	                        {if ($item.trial_vi == "y") || ($licensed==true)}
    	                            {*<a href="javascript:;" class="btn-highlight btn-quiz ml-5 {if ($quizs_answer_pass|@count < 1) && ($item.trial_vi != "y")}d-none{/if}" data-bs-toggle="modal" data-bs-target="#modalQuiz{$item.quiz_id_vi}" data-id-quiz="{$item.quiz_id_vi}">*}
    	                            <a href="javascript:;" 
    	                                class="btn-highlight btn-quiz ml-5" 
    	                                data-bs-toggle="modal" 
    	                                data-bs-target="#modalQuiz{$item.quiz_id_vi}" 
    	                                data-id-quiz="{$item.quiz_id_vi}"
    	                                data-class-room-id="{if !empty($classRoomCurrent)}{$classRoomCurrent}{/if}"
    	                                data-product-id="{$product.id}"
    	                                data-customer-id="{if !empty($code_member)}{$code_member}{/if}"
    	                                data-lesson-name="{$item.name_vi}"
    	                                data-lesson-code="{$item.code}"
    	                            >
                                        Kiểm tra
                                    </a>
                                {/if}
                            {/if}
    	                </div>
    	                {if !empty($item.filestwo)}
    	                    {assign var = filestwo value = $item.filestwo|json_decode:1}
    	                    {*<div class="inner-files my-10 px-10 {if ($quizs_answer_pass|@count < 1) && ($item.trial_vi != "y")}d-none{/if}">*}
    	                    <div class="inner-files my-10 px-10">
    	                        <strong class="color-black fs-10 d-inline-block mr-5 my-5">Tài liệu bài học: </strong>
    	                        {if ($item.trial_vi == "y") || $licensed==true}
                    			    {foreach from = $filestwo key = key2 item = file}
        	                            {assign var = file_name value = $this->Utilities->getFileNameInUrl($file)}
                                        
                                        <a href="javascript:;" btn-view-file class="bg-primary py-1 fs-10 text-white px-2 rounded d-inline-block mr-5 mb-5" data-bs-toggle="modal" data-bs-target="#previewFile" data-file="https://meduc.vn/cdn{$this->Utilities->checkInternalUrl($file)}" data-name="{urldecode($file_name)}">
                                          {urldecode($file_name)}
                                        </a>

        	                        {/foreach}
                                {else}
                                    <i class="iconsax isax-lock isax-lg color-main"></i>
                                {/if}
    	                    </div>
	                    {/if}
    	            </div>
                {/if}
        	{/foreach}
        </div>
    </div>
    
    {*if !empty($product.attributes.thongtingiangvien.value)}
        <div class="course-details-card mt--40" nh-anchor="giangvien">
            <div class="title-section-2">
                <span>Thông tin giảng viên</span>
            </div>
            {$thongtingiangvien = $this->Article->getArticles([
                'filter' => [
                    'ids' => json_decode($product.attributes.thongtingiangvien.value, true)
                ],
                'get_attributes' => true
            ])}
            <div class="content-format">
                <div class="course-author-wrapper">
                    <div class="thumbnail">
                        <img src="{CDN_URL}{$thongtingiangvien[0].image_avatar}" alt="{$thongtingiangvien[0].name}" />
                    </div>
                    <div class="author-content">
                        <span class="subtitle">Giảng viên</span>
                        <h6 class="title">
                            <a href="{$thongtingiangvien[0].url}">{$thongtingiangvien[0].name}</a>
                        </h6>
                        <p>{$thongtingiangvien[0].description|strip_tags}</p>
                    </div>
                </div>
            </div>
        </div>
    {/if*}
    
    {assign quizs value = $this->Product->getQuizs(['lesson_list' => $danhsachtiethoc])}

    {if !empty($quizs)}
        {*if ($item.trial_vi == "y") || ($licensed==true)*}
        <div
            data-quizs="{htmlentities($quizs|@json_encode)}"
            list-form-quiz=""
            data-desc="{if !empty($data_extend['locale'][{LANGUAGE}]['text_1'])}{htmlentities($this->Block->getLocale('text_1', $data_extend))}{/if}"
            data-product-id="{$product.id}"
            data-member-id="{if !empty($member_info.id)}{$member_info.id}{/if}"
            data-member-code="{if !empty($code_member)}{$code_member}{/if}"
            data-class-room-id="{if !empty($classRoomCurrent)}{$classRoomCurrent}{/if}"
        ></div>
        {*if ($licensed==true)}
            {foreach from = $quizs key = key item = item}
                {foreach from = $item.QuizsAttribute item = attr}
                    {if ($attr.attribute_id == 18)}
                        {assign var = questions value = $attr.value|json_decode:1}
                    {elseif ($attr.attribute_id == 19)}
                        {assign var = time value = $attr.value}
                    {/if}
                {/foreach}
                
                <div data-clock-quiz="{$item.id}" class="clock-quiz" data-time="{$time}" data-time-work="0">
                    <span class="inner-label">Còn lại</span>
                    <span class="inner-time">
                        <span class="inner-minutes">0</span>p
                        :
                        <span class="inner-seconds">0</span>s
                    </span>
                </div>
                
                <div class="modal fade modal-preview-file" id="modalQuiz{$item.id}" tabindex="-1" aria-hidden="true" data-bs-backdrop="static" data-bs-keyboard="false">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title">{$item.QuizsContent.name} (Thời gian: {$time} phút)</h5>
                                <button close-clock-quiz="{$item.id}" type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                            <div class="modal-body bg-logo">
                                <form form-quiz-id="{$item.id}" class="form-quiz">
                                    <div class="container">
                                        <div class="row">
                                            <div class="col-xl-9 col-lg-9 col-md-9 col-sm-12 col-12 my-15">
                                                {if !empty($data_extend['locale'][{LANGUAGE}]['text_1'])}
                                                    <div class="mb-20 fw-bold color-main">
                                                        {$this->Block->getLocale('text_1', $data_extend)|nl2br}
                                                    </div>
                                                {/if}
                                                
                                                <input name="quiz_id" value="{$item.id}" class="d-none" />
                                                <input name="product_id" value="{$product.id}" class="d-none" />
                                                <input name="customer_id" value="{if !empty($member_info.id)}{$member_info.id}{/if}" class="d-none" />
                                                
                                                {foreach from = $questions key = key item = question}
                                                    <div class="form-quiz__item" id="target-{$item.id}-{$key}">
                                                        <h5 class="form-quiz__item-title">{$question.name_vi}</h5>
                                                        {if !empty($question.description_vi)}
                                                            <div class="form-quiz__item-desc">
                                                                {$question.description_vi}
                                                            </div>
                                                        {/if}
                                                        <div class="form-quiz__item-ques">
                                                            {if !empty($question.option_one_vi)}
                                                                <div class="form-check">
                                                                    <input class="form-check-input {if ($question.answer_vi == "1")}form-check-input--success{/if}" type="radio" name="{$question.code}" id="question1_{$question.code}" value="1">
                                                                    <label class="form-check-label" for="question1_{$question.code}">
                                                                        {$question.option_one_vi}
                                                                    </label>
                                                                </div>
                                                            {/if}
                                                            {if !empty($question.option_two_vi)}
                                                                <div class="form-check">
                                                                    <input class="form-check-input {if ($question.answer_vi == "2")}form-check-input--success{/if}" type="radio" name="{$question.code}" id="question2_{$question.code}" value="2">
                                                                    <label class="form-check-label" for="question2_{$question.code}">
                                                                        {$question.option_two_vi}
                                                                    </label>
                                                                </div>
                                                            {/if}
                                                            {if !empty($question.option_three_vi)}
                                                                <div class="form-check">
                                                                    <input class="form-check-input {if ($question.answer_vi == "3")}form-check-input--success{/if}" type="radio" name="{$question.code}" id="question3_{$question.code}" value="3">
                                                                    <label class="form-check-label" for="question3_{$question.code}">
                                                                        {$question.option_three_vi}
                                                                    </label>
                                                                </div>
                                                            {/if}
                                                            {if !empty($question.option_four_vi)}
                                                                <div class="form-check">
                                                                    <input class="form-check-input {if ($question.answer_vi == "4")}form-check-input--success{/if}" type="radio" name="{$question.code}" id="question4_{$question.code}" value="4">
                                                                    <label class="form-check-label" for="question4_{$question.code}">
                                                                        {$question.option_four_vi}
                                                                    </label>
                                                                </div>
                                                            {/if}
                                                            {if !empty($question.option_five_vi)}
                                                                <div class="form-check">
                                                                    <input class="form-check-input {if ($question.answer_vi == "5")}form-check-input--success{/if}" type="radio" name="{$question.code}" id="question5_{$question.code}" value="5">
                                                                    <label class="form-check-label" for="question5_{$question.code}">
                                                                        {$question.option_five_vi}
                                                                    </label>
                                                                </div>
                                                            {/if}
                                                        </div>
                                                        {if !empty($question.answer_detail_vi)}
                                                            <div class="form-quiz__answer">
                                                                <h5>Đáp án chi tiết:</h5>
                                                                <div class="form-quiz__answer-detail">
                                                                    {$question.answer_detail_vi}
                                                                </div>
                                                            </div>
                                                        {/if}
                                                    </div>
                                                {/foreach}
                                                <div class="mt-40">
                                                    <button class="edu-btn btn-submit-quiz" btn-submit-quiz="{$item.id}">Nộp bài</button>
                                                </div>
                                                
                                                <div class="form-quiz__result--modal">
                                                    <div class="form-quiz__result">
                                                        <h5 class="inner-head">Kết quả:</h5>
                                                        <div class="row">
                                                            <div class="col-xl-3 col-lg-3 col-md-6 col-sm-6 col-12 my-10">
                                                                <p>Tổng số câu: <span class="inner-total">0</span></p>
                                                            </div>
                                                            <div class="col-xl-3 col-lg-3 col-md-6 col-sm-6 col-12 my-10">
                                                                <p>Số câu đúng: <span class="inner-correct">0</span></p>
                                                            </div>
                                                            <div class="col-xl-3 col-lg-3 col-md-6 col-sm-6 col-12 my-10">
                                                                <p>Số câu sai: <span class="inner-false">0</span></p>
                                                            </div>
                                                            <div class="col-xl-3 col-lg-3 col-md-6 col-sm-6 col-12 my-10">
                                                                <p>Tỷ lệ đúng: <span class="inner-ratio"></span></p>
                                                            </div>
                                                            <div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 my-10">
                                                                <p><span class="inner-result"></span></p>
                                                            </div>
                                                        </div>
                                                        <div class="mt-30">
                                                            <span class="edu-btn btn-reset-quiz" btn-reset-quiz="{$item.id}">Làm lại</span>
                                                            <span class="edu-btn btn-reload">Xem lại bài học</span>
                                                            <span class="edu-btn btn-result">Đáp án chi tiết</span>
                                                            <span class="edu-btn btn-continue">Học tiếp</span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-xl-3 col-lg-3 col-md-3 col-sm-12 col-12 my-15">
                                                <div class="form-quiz__result-toc">
                                                    <div class="inner-box">
                                                        <div class="inner-head">
                                                            <div class="inner-title">
                                                                Bấm vào câu đã làm
                                                            </div>
                                                            <div class="inner-desc">
                                                                để xem lại đáp án + lời giải chi tiết
                                                            </div>
                                                        </div>
                                                        <div class="inner-wrap">
                                                            {foreach from = $questions key = key item = question}
                                                                <a href="#target-{$item.id}-{$key}">
                                                                    {$key + 1}
                                                                </a>
                                                            {/foreach}
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            {/foreach}
        {/if*}
        
        <div class="modal fade modal-preview-file" id="previewFile" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-xl">
                <div class="modal-content">
                    <div class="modal-header">
                        <div class="modal-title fs-16">Tài liệu: <span></span></div>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div id="pdf_container" class="pdf-container"></div>
                    </div>
                </div>
            </div>
        </div>
    {/if}
{else}
	<p class="text-center font-danger mt-10">{__d('template', 'thong_tin_san_pham_khong_ton_tai')}</p>
{/if}
