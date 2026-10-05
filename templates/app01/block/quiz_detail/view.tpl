{assign var = article_info value = []}
{if !empty($data_block.data)}
	{assign var = article_info value = $data_block.data}
{/if}
{if !empty($article_info)}
    {strip}
    	{assign member_info value = $this->Member->getMemberInfo()}
    	
        {assign show_answer value = $article_info.attributes.hienthidapan.value}
        
        <div class="rbt-course-action-bottom">
            <div class="read-more-btn">
                <a href="/khoa-hoc" class="edu-btn w-100 text-center btn-ani">
                    Tìm Hiểu Khóa Học
                </a>
            </div>
        </div>

    	<article class="article-detail bg-logo mb-30">
    		{if !empty($article_info.name)}
    			<h2 class="article-title-detail">
    				{$article_info.name|escape}
    			</h2>
    		{/if}
    		{*if !empty($article_info.url)}

	            {assign var = url_article value = "{$this->Utilities->getUrlWebsite()}{$this->Utilities->checkInternalUrl($article_info.url)}"}
	            <div class="social-share d-flex align-items-center flex-wrap" style="background: #ffffffde;">
	                <span class="share-title">
	                    <b>{__d('template', 'chia_se')}: </b>
	                </span>
	                <div class="list-social">
                        <div class="btn-social facebook-icon">
                            <a href="javascript:;" nh-link-redirect="https://www.facebook.com/sharer/sharer.php?u={$url_article}" target="_blank" title="Facebook">
                            	{$this->LazyLoad->renderImage([
		                            'src' => "{URL_TEMPLATE}assets/img/icon/facebook-f.svg", 
		                            'alt' => "{__d('template', 'facebook')}",
		                            'class' => 'img-fluid svg-white'
		                        ])}
                            </a>
                        </div>

                        <div class="btn-social twitter-icon">
                            <a href="javascript:;" nh-link-redirect="https://twitter.com/share?url={$url_article}" target="_blank" title="Twitter">
                            	{$this->LazyLoad->renderImage([
		                            'src' => "{URL_TEMPLATE}assets/img/icon/twitter.svg", 
		                            'alt' => "{__d('template', 'twitter')}",
		                            'class' => 'img-fluid svg-white'
		                        ])}
                            </a>
                        </div>

                        <div class="btn-social google-icon">
                            <a href="javascript:;" nh-link-redirect="https://plus.google.com/share?url={$url_article}" target="_blank" title="Google+">
                            	{$this->LazyLoad->renderImage([
		                            'src' => "{URL_TEMPLATE}assets/img/icon/google-plus.svg", 
		                            'alt' => "{__d('template', 'google')}",
		                            'class' => 'img-fluid svg-white'
		                        ])}
                            </a>
                        </div>

                        <div class="btn-social pinterest-icon">
                            <a href="javascript:;" nh-link-redirect="https://pinterest.com/pin/create/button/?url={$url_article}" target="_blank" title="Pinterest">
                            	{$this->LazyLoad->renderImage([
		                            'src' => "{URL_TEMPLATE}assets/img/icon/pinterest-p.svg", 
		                            'alt' => "{__d('template', 'pinterest')}",
		                            'class' => 'img-fluid svg-white'
		                        ])}
                            </a>
                        </div>

                        <div class="btn-social linkedin-icon">
                            <a href="javascript:;" nh-link-redirect="https://www.linkedin.com/shareArticle?mini=true&amp;url={$url_article}" target="_blank" title="LinkedIn">
                            	{$this->LazyLoad->renderImage([
		                            'src' => "{URL_TEMPLATE}assets/img/icon/linkedin.svg", 
		                            'alt' => "{__d('template', 'linkedin')}",
		                            'class' => 'img-fluid svg-white'
		                        ])}
                            </a>
                        </div>
                    </div>
	            </div>
            {/if*}
            
    	    <form class="form-quiz form-quiz-detail">
        	    <div class="">
                    <div class="row">
                        <div class="col-xl-9 col-lg-9 col-md-9 col-sm-12 col-12 my-15">
                            <input name="quiz_id" value="{$article_info.id}" class="d-none" />
                            <input name="customer_id" value="{if !empty($member_info.id)}{$member_info.id}{/if}" class="d-none" />
                            
                            {if !empty($article_info.attributes.danhsachcauhoi.value)}
                                {assign questions value = $article_info.attributes.danhsachcauhoi.value|json_decode:1}
                                
                                {foreach from = $questions key = key item = question}
                                    <div class="form-quiz__item" id="target-{$key}">
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
                                            <div class="form-quiz__answer {if ($show_answer == "1")}d-none{/if}">
                                                <h5>Đáp án chi tiết:</h5>
                                                <div class="form-quiz__answer-detail">
                                                    {$question.answer_detail_vi}
                                                </div>
                                            </div>
                                        {/if}
                                    </div>
                                {/foreach}
                            {/if}
                            <div class="mt-30">
                                <button class="edu-btn btn-submit-quiz">Nộp bài</button>
                            </div>
                            
                            <div class="form-quiz__result--modal">
                                <div class="form-quiz__result">
                                    <h5 class="inner-head">Kết quả:</h5>
                                    <div class="row">
                                        <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6 col-12 my-10">
                                            <p>Tổng số câu: <span class="inner-total">0</span></p>
                                        </div>
                                        <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6 col-12 my-10">
                                            <p>Số câu đúng: <span class="inner-correct">0</span></p>
                                        </div>
                                        <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6 col-12 my-10">
                                            <p>Số câu sai: <span class="inner-false">0</span></p>
                                        </div>
                                        <div class="col-xl-3 col-lg-6 col-md-6 col-sm-6 col-12 my-10">
                                            <p>Tỷ lệ đúng: <span class="inner-ratio"></span></p>
                                        </div>
                                    </div>
                                    <div class="mt-30">
                                        <span class="edu-btn btn-reset-quiz mr-10">Làm lại</span>
                                        <span class="edu-btn btn-result mr-10">Đáp án chi tiết</span>
                                        <span class="edu-btn btn-continue mr-10">Thi đề mới</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-xl-3 col-lg-3 col-md-3 col-sm-12 col-12 my-15">
                            <div class="form-quiz--right">
                               <div class="form-quiz--fixed">
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
                                                    <a href="#target-{$key}">
                                                        {$key + 1}
                                                    </a>
                                                {/foreach}
                                            </div>
                                        </div>
                                    </div>
                                </div> 
                            </div>
                        </div>
                    </div>
                </div>
                
                {if !empty($data_extend['locale'][{LANGUAGE}]['nut_bam'])}
                    <div class="text-center mt-30 btn-learn-try">
                        <div class="read-more-btn" data-sal-delay="450" data-sal="slide-up" data-sal-duration="800">
                            <a class="edu-btn btn-ani" href="{if !empty($data_extend['locale'][{LANGUAGE}]['link_nut_bam'])}{$this->Block->getLocale('link_nut_bam', $data_extend)}{/if}">
                                {$this->Block->getLocale('nut_bam', $data_extend)|nl2br} <i class="icon-arrow-right-line-right"></i>
                            </a>
                        </div>
                    </div>
                {/if}
                
                {if !empty($data_extend['locale'][{LANGUAGE}]['text_1'])}
                    <div class="mb-20 fw-bold color-main">
                        {$this->Block->getLocale('text_1', $data_extend)|nl2br}
                    </div>
                {/if}
                
                {if !empty($article_info.url)}

    	            {assign var = url_article value = "{$this->Utilities->getUrlWebsite()}{$this->Utilities->checkInternalUrl($article_info.url)}"}
    	            <div class="social-share d-flex align-items-center flex-wrap mt-30">
    	                <span class="share-title">
    	                    <b>{__d('template', 'chia_se')}: </b>
    	                </span>
    	                <div class="list-social">
                            <div class="btn-social facebook-icon">
                                <a href="javascript:;" nh-link-redirect="https://www.facebook.com/sharer/sharer.php?u={$url_article}" target="_blank" title="Facebook">
                                	{$this->LazyLoad->renderImage([
    		                            'src' => "{URL_TEMPLATE}assets/img/icon/facebook-f.svg", 
    		                            'alt' => "{__d('template', 'facebook')}",
    		                            'class' => 'img-fluid svg-white'
    		                        ])}
                                </a>
                            </div>
    
                            <div class="btn-social twitter-icon">
                                <a href="javascript:;" nh-link-redirect="https://twitter.com/share?url={$url_article}" target="_blank" title="Twitter">
                                	{$this->LazyLoad->renderImage([
    		                            'src' => "{URL_TEMPLATE}assets/img/icon/twitter.svg", 
    		                            'alt' => "{__d('template', 'twitter')}",
    		                            'class' => 'img-fluid svg-white'
    		                        ])}
                                </a>
                            </div>
    
                            <div class="btn-social google-icon">
                                <a href="javascript:;" nh-link-redirect="https://plus.google.com/share?url={$url_article}" target="_blank" title="Google+">
                                	{$this->LazyLoad->renderImage([
    		                            'src' => "{URL_TEMPLATE}assets/img/icon/google-plus.svg", 
    		                            'alt' => "{__d('template', 'google')}",
    		                            'class' => 'img-fluid svg-white'
    		                        ])}
                                </a>
                            </div>
    
                            <div class="btn-social pinterest-icon">
                                <a href="javascript:;" nh-link-redirect="https://pinterest.com/pin/create/button/?url={$url_article}" target="_blank" title="Pinterest">
                                	{$this->LazyLoad->renderImage([
    		                            'src' => "{URL_TEMPLATE}assets/img/icon/pinterest-p.svg", 
    		                            'alt' => "{__d('template', 'pinterest')}",
    		                            'class' => 'img-fluid svg-white'
    		                        ])}
                                </a>
                            </div>
    
                            <div class="btn-social linkedin-icon">
                                <a href="javascript:;" nh-link-redirect="https://www.linkedin.com/shareArticle?mini=true&amp;url={$url_article}" target="_blank" title="LinkedIn">
                                	{$this->LazyLoad->renderImage([
    		                            'src' => "{URL_TEMPLATE}assets/img/icon/linkedin.svg", 
    		                            'alt' => "{__d('template', 'linkedin')}",
    		                            'class' => 'img-fluid svg-white'
    		                        ])}
                                </a>
                            </div>
                        </div>
    	            </div>
                {/if}
            </form>
            
            {if !empty($article_info.attributes.thoigianlambai.value)}
                {assign time value = $article_info.attributes.thoigianlambai.value}
                <div class="clock-quiz active" data-time="{$time}" data-time-work="0">
                    <span class="inner-label">Còn lại</span>
                    <span class="inner-time">
                        <span class="inner-minutes">0</span>p
                        :
                        <span class="inner-seconds">0</span>s
                    </span>
                </div>
            {/if}
    	</article>
    {/strip}
{/if}