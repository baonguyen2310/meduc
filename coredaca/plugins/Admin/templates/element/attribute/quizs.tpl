{if !empty($code)}
	{assign var = filemanager_access_key value = {$this->SystemAdmin->getAccessKeyUpload()}}
	{assign var = quizs value = []}
	{if !empty($value)}
		{$quizs = $value|json_decode:1}
	{/if}

	<div class="row wrap-album">
	    <div class="col-xl-8 col-lg-8">
	        <input id="{$code}" name="{$code}" value="{if !empty($value)}{htmlentities($value)}{/if}" type="hidden" input-attribute="quizs" />
	        <div class="clearfix mb-5 list-quiz-album">
	            {if !empty($quizs)}
	                {foreach from = $quizs item = quiz}
	                    <a href="{CDN_URL}{$quiz}" target="_blank" class="kt-media kt-media--lg mr-10 position-relative item-quiz-album" data-quiz="{$quiz}">
	                        <img src="{CDN_URL}{$quiz}">
	                        <span class="btn-clear-quiz-album" title="{__d('admin', 'xoa_anh')}">
	                            <i class="fa fa-times"></i>
	                        </span>
	                    </a>
	                {/foreach}
	            {/if}
	        </div>
	    </div>
	    <div class="col-xl-2 col-lg-4">
	        <span class="col-12 btn btn-sm btn-success btn-select-quiz-album" data-src="{CDN_URL}/filemanager/dialog.php?type=1&crossdomain=1&akey={$filemanager_access_key}&field_id={$code}&lang={LANGUAGE_ADMIN}" data-type="iframe">
	            <i class="fa fa-images"></i> 
	            {__d('admin', 'chon_anh')}
	        </span>
	    </div>
	</div>
{/if}