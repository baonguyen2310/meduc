{strip}{assign memberInfo value = $this->Member->getMemberInfo()}
{assign var = id value = $this->Utilities->getParamsByKey('id')}

{if !empty($memberInfo) && !empty($id)}
    {assign var = resultQuiz value = $this->Utilities->getResultQuiz($memberInfo.code, $id)}

    {if !empty($resultQuiz)}
        <article class="article-detail my-60">
            {if !empty($resultQuiz.quiz_name)}
    			<h1 class="fs-24">
    				Kết quả: {$resultQuiz.quiz_name|escape}
    				{if !empty($resultQuiz.class_name)}
    				    <span class="ml-10">({$resultQuiz.class_name|escape})</span>
    				{/if}
    			</h1>
    		{/if}
    		
    		<div>
    		    {if !empty($resultQuiz.answer_total)}
    		        <span class="badge bg-light text-dark fs-13 mr-10">Tổng số câu: {$resultQuiz.answer_total}</span>
    		    {/if}
    		    {if !empty($resultQuiz.answer_correct)}
    		        <span class="badge bg-success fs-13 mr-10">Đúng: {$resultQuiz.answer_correct}</span>
    		    {/if}
    		    {if !empty($resultQuiz.answer_wrong)}
    		        <span class="badge bg-danger fs-13 mr-10">Sai: {$resultQuiz.answer_wrong}</span>
    		    {/if}
    		    {if !empty($resultQuiz.answer_correct_percent)}
    		        <span class="badge bg-light text-dark fs-13 mr-10">Tỷ lệ đúng: {$resultQuiz.answer_correct_percent}%</span>
    		    {/if}
    		    {if !empty($resultQuiz.total_time)}
    		        <span class="badge bg-light text-dark fs-13 mr-10">Tổng thời gian: {$resultQuiz.total_time}</span>
    		    {/if}
    		    {if !empty($resultQuiz.created)}
    		        <span class="badge bg-light text-dark fs-13 mr-10">Ngày làm bài: {$this->Utilities->convertIntgerToDateTimeString($resultQuiz.created)}</span>
    		    {/if}
    		</div>
    		
    		{if !empty($resultQuiz.questionsAnswers)}
        		<div class="form-quiz form-quiz-detail form-quiz--success form-quiz--show-result">
            	    <div class="">
                        <div class="row">
                            <div class="col-xl-8 col-lg-8 col-md-8 col-sm-12 col-12 my-15 order-md-1 order-2">
                                {foreach from = $resultQuiz.questionsAnswers key = key item = question}
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
                                                    <input class="form-check-input {if ($question.answer_vi == "1")}form-check-input--success{/if}" {if ($question.answer_choose == "1")}checked="checked"{/if} type="radio" name="{$question.code}" id="question1_{$question.code}" value="1">
                                                    <label class="form-check-label" for="question1_{$question.code}">
                                                        {$question.option_one_vi}
                                                    </label>
                                                </div>
                                            {/if}
                                            {if !empty($question.option_two_vi)}
                                                <div class="form-check">
                                                    <input class="form-check-input {if ($question.answer_vi == "2")}form-check-input--success{/if}" {if ($question.answer_choose == "2")}checked="checked"{/if} type="radio" name="{$question.code}" id="question2_{$question.code}" value="2">
                                                    <label class="form-check-label" for="question2_{$question.code}">
                                                        {$question.option_two_vi}
                                                    </label>
                                                </div>
                                            {/if}
                                            {if !empty($question.option_three_vi)}
                                                <div class="form-check">
                                                    <input class="form-check-input {if ($question.answer_vi == "3")}form-check-input--success{/if}" {if ($question.answer_choose == "3")}checked="checked"{/if} type="radio" name="{$question.code}" id="question3_{$question.code}" value="3">
                                                    <label class="form-check-label" for="question3_{$question.code}">
                                                        {$question.option_three_vi}
                                                    </label>
                                                </div>
                                            {/if}
                                            {if !empty($question.option_four_vi)}
                                                <div class="form-check">
                                                    <input class="form-check-input {if ($question.answer_vi == "4")}form-check-input--success{/if}" {if ($question.answer_choose == "4")}checked="checked"{/if} type="radio" name="{$question.code}" id="question4_{$question.code}" value="4">
                                                    <label class="form-check-label" for="question4_{$question.code}">
                                                        {$question.option_four_vi}
                                                    </label>
                                                </div>
                                            {/if}
                                            {if !empty($question.option_five_vi)}
                                                <div class="form-check">
                                                    <input class="form-check-input {if ($question.answer_vi == "5")}form-check-input--success{/if}" {if ($question.answer_choose == "5")}checked="checked"{/if} type="radio" name="{$question.code}" id="question5_{$question.code}" value="5">
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
                            </div>
                            <div class="col-xl-4 col-lg-4 col-md-4 col-sm-12 col-12 my-15 order-md-2 order-1">
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
                                                    {foreach from = $resultQuiz.questionsAnswers key = key item = question name = questionLoop}
                                                        <a href="#target-{$key}" class="{if ($question.answer_vi == $question.answer_choose)}true{else}false{/if}">
                                                            {$smarty.foreach.questionLoop.index + 1}
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
                </div>
            {/if}
        </article>
    {/if}
{/if}{/strip}