<form id="form-apply-attributes" action="{ADMIN_PATH}/setting/save/attributes_category" method="POST" autocomplete="off">
    <div class="kt-portlet__head">
        <div class="kt-portlet__head-label">
            <h3 class="kt-portlet__head-title">
                {__d('admin', 'thuoc_tinh_mo_rong')}
            </h3>
        </div>
    </div>

    <div class="kt-portlet__body">
        <div class="kt-scroll" data-scroll="true" data-height="520" nh-list-attributes>
            {if !empty($attributes)}
                <div class="row">
                    {foreach from=$attributes key=key item=item}

                        {assign var = attribute_id value = ""}
                        {if !empty($item.id)}
                            {assign var = attribute_id value = $item.id}
                        {/if}

                        {assign var = checked value = ""}
                        {if !empty($attribute_id) && !empty($data_apply) && in_array($attribute_id,$data_apply)}
                            {assign var = checked value = "checked"}
                        {/if}
                        <div class="col-sm-6 col-12">
                            {if !empty($item.AttributesContent.name)}
                                <label class="kt-checkbox kt-checkbox--tick kt-checkbox--success">
                                    <input type="checkbox" value="{if !empty($attribute_id)}{$attribute_id}{/if}" name="attribute[]" {$checked}> {$item.AttributesContent.name}
                                    <span></span>
                                </label>
                            {/if}
                        </div>
                    {/foreach}
                </div>
            {/if}
        </div> 
    </div>

    <div class="kt-portlet__foot">
        <div class="kt-form__actions">
            <button type="button" class="btn btn-sm btn-brand btn-save">
                {__d('admin', 'luu_thong_tin')}
            </button>
        </div>
    </div>
</form>