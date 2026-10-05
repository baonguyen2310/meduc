<!--begin::Modal-->
<div class="modal fade" id="modal-change-status-learn" tabindex="-1" role="dialog" aria-labelledby="" aria-hidden="true">
    <div class="modal-dialog modal-md" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="">Thay đổi trạng thái học</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true" class="la la-remove"></span>
                </button>
            </div>
            <form id="status-learn-form" class="kt-form kt-form--fit" action="{ADMIN_PATH}/customer/status-learn{if !empty($id)}/{$id}{/if}" method="POST" autocomplete="off" >
                <div class="modal-body">
                    <label>
                        Trạng thái học
                    </label>
                    <select name="status_learn" id="status-learn" class="form-control form-control-sm kt-selectpicker">
                        <option>
                            Chưa thiết lập
                        </option>
                        <option value="danghoc" {if isset($customer.status_learn) && $customer.status_learn == "danghoc"}selected="true"{/if}>
                            Đang học
                        </option>
                        <option value="hoanthanh" {if isset($customer.status_learn) && $customer.status_learn == "hoanthanh"}selected="true"{/if}>
                            Hoàn thành
                        </option>
                        <option value="baoluu" {if isset($customer.status_learn) && $customer.status_learn == "baoluu"}selected="true"{/if}>
                            Bảo lưu
                        </option>
                        <option value="nghihoc" {if isset($customer.status_learn) && $customer.status_learn == "nghihoc"}selected="true"{/if}>
                            Nghỉ học
                        </option>
                   </select>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-sm btn-primary btn-status-learn">{__d('admin', 'thay_doi')}</button>
                </div>
            </form>
        </div>
    </div>
</div>
<!--end::Modal-->