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
                        <input type="checkbox" value="{if !empty($attribute_id)}{$attribute_id}{/if}" name="attributes[]" {$checked}> {$item.AttributesContent.name}
                        <span></span>
                    </label>
                {/if}
            </div>
        {/foreach}
    </div>
{/if}

<input type="hidden" name="category_id" value="{if !empty($category_id)}{$category_id}{/if}">