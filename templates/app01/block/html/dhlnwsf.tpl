{strip}{assign var = form_url value = $this->Block->getLocale('duong_dan_tim_kiem', $data_extend)}

<div class="my-50">
	{if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
        <div class="row">
            <div class="col-lg-12">
                <div class="section-title text-center mb--30" data-sal-delay="150" data-sal="slide-up" data-sal-duration="800">
                    {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de_phu'])}
                    <span class="pre-title">{$this->Block->getLocale('tieu_de_phu', $data_extend)|nl2br}</span>
                    {/if}
                    <h3 class="title">{$this->Block->getLocale('tieu_de', $data_extend)|nl2br}</h3>
                </div>
            </div>
        </div>
    {/if}

    <form action="{$form_url}" method="get" autocomplete="off" class="box-suggest position-relative">
		<div class="input-group">
			<input nh-auto-suggest="product" name="keyword" value="{$this->Utilities->getParamsByKey('keyword')}" placeholder="{__d('template', 'tu_khoa_tim_kiem')}" type="text" class="form-control form-control-sm">
			<div class="input-group-append">
				<span class="btn" nh-btn-submit>{__d('template', 'tim_kiem')}</span>
			</div>
		</div>
	</form>
</div>{/strip}