{if !empty($code)}
    {assign var = quizs value = []}
    {if !empty($value)}
        {$quizs = $value|json_decode:1}
    {/if}
    <div class="wrap-auto-suggest">
        <div class="row">
            <div class="col-lg-6 col-12">
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-prepend">
                            <span class="input-group-text">
                                <i class="flaticon-search w-20px"></i>
                            </span>
                        </div>
                        <input id="{$code}-suggest" value="" type="text" class="form-control form-control-sm" placeholder="{__d('admin', 'nhap_ten_va_chon_bai_viet')}" autocomplete="off" input-attribute="{QUIZ_SELECT}" input-attribute-code="{$code}">
                    </div>
                </div>
            </div>
        </div>
        
        <div class="form-group">
            <div class="input-group">
                <div class="input-group-prepend">
                    <span class="input-group-text">
                        <i class="fa fa-layer-group w-20px"></i>
                    </span>
                </div>
                <div id="wrap-data-selected" class="form-control form-control-sm clearfix mh-35 tagify" style="padding:2px 0 !important;">
                    {if !empty($quizs)}
                        {foreach from = $quizs item = quiz_id}
                            {assign var = quiz_info value = $this->QuizAdmin->getDetailQuiz($quiz_id, LANGUAGE_ADMIN)}
                            <span class="tagify__tag">
                                <x class="tagify__tag__removeBtn" role="button"></x>
                                <div>
                                    <span class="tagify__tag-text">
                                        {if !empty($quiz_info.name)}
                                            {$quiz_info.name}
                                        {/if}
                                    </span>
                                </div>
                                <input name="{$code}[]" value="{if !empty($quiz_info.id)}{$quiz_info.id}{/if}" type="hidden">
                            </span>
                        {/foreach}
                    {/if}
                </div>
            </div>
        </div>
    </div>
	
{/if}