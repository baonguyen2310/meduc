<form nh-form="associate-bank" action="/member/bank/save" method="post" autocomplete="off">
    <div class="form-group">
        <label class="font-weight-normal" for="bank_key">
            {__d('template', 'ten_ngan_hang')}: 
        </label>
        <input name="bank_key" value="" type="text" class="bg-white border form-control rounded input-hover" autocomplete="off">
        {*$this->Form->select('bank_key', $this->Member->getListBank(), ['id' => 'bank_key', 'empty' => "-- {__d('template', 'ten_ngan_hang')} --", 'class' => 'form-control selectpicker input-hover', 'data-size' => 10, 'data-live-search' => true])*}
    </div>

    <div class="form-group">
        <label class="font-weight-normal" for="bank_branch">
            {__d('template', 'chi_nhanh')}: 
        </label>
        <input name="bank_branch" value="" type="text" class="bg-white border form-control rounded input-hover" autocomplete="off">
    </div>
   
    <div class="form-group">
        <label class="font-weight-normal" for="account_holder">
            {__d('template', 'chu_tai_khoan')}: 
        </label>
        <input name="account_holder" value="" type="text" class="bg-white border form-control rounded input-hover" autocomplete="off">
    </div>

    <div class="form-group">
        <label class="font-weight-normal" for="account_number">
            {__d('template', 'so_tai_khoan')}: 
        </label>
        <input name="account_number" value="" type="text" class="bg-white border form-control rounded input-hover" autocomplete="off">
    </div>
        
    <input name="bank_id" type="hidden" value="">

    <div class="form-group btn-submit-form">
        <span nh-btn-action="submit" class="btn btn-primary py-2 px-20 fs-15 w-100 text-center">
            {__d('template', 'cap_nhat')}
        </span>
    </div>
</form>