{if !empty($attributes)}
    <form id="config-attribute-form" action="{ADMIN_PATH}/setting/export-data/config-attributes" method="POST" autocomplete="off">
        {foreach from=$attributes key=key item=attribute}
            {assign var = attribute_id value = ''}
            {if !empty($attribute.id)}
                {assign var = attribute_id value = $attribute.id}
            {/if}

            <div class="form-group">
                <label class="kt-checkbox kt-checkbox--tick kt-checkbox--success mb-0">
                    <input type="checkbox" name="ids[]" value="{$attribute_id}" {if !empty($attribute_id) && !empty($migrate_attributes) && in_array($attribute_id, $migrate_attributes)}checked{/if}> 
                    {if !empty($attribute.AttributesContent.name)}
                        {$attribute.AttributesContent.name}
                    {/if}
                    <span></span>
                </label>
            </div>
        {/foreach}

        <input type="hidden" name="attribute_type" value="{if !empty($attribute_type)}{$attribute_type}{/if}">
    </form>
{/if}