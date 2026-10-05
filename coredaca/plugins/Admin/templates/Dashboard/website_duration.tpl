<div class="kt-portlet__head">
    <div class="kt-portlet__head-label">
        <h3 class="kt-portlet__head-title">
            {__d('admin', 'dung_luong')}
        </h3>
    </div>

    <div class="kt-portlet__head-toolbar">
        {if !empty($capacity)}
            <span class="kt-font-danger fs-16 font-weight-bold">
                {$capacity} GB
            </span>
        {/if}
    </div>
</div>
{*
<div class="kt-portlet__body p-10 d-none">
    {if !empty($capacity)}
        <div id="chart-website-space" style="height: 215px;"></div>
        <div class="text-center">
            {__d('admin', 'tong_dung_luong')}: {$capacity} GB
        </div>
        <div class="text-center">
            {__d('admin', 'da_dung')}: {$used} GB
        </div>

        <input id="data-chart-space" type="hidden" value="{if !empty($data_chart)}{htmlentities($data_chart|@json_encode)}{/if}">
    {else}
        <i class="text-center">{__d('admin', 'chua_xac_dinh')}</i>
    {/if}
</div>
*}