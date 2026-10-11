{assign var = filemanager_access_key value = {$this->SystemAdmin->getAccessKeyUpload()}}

<div class="kt-subheader kt-grid__item" id="kt_subheader">
    <div class="kt-container  kt-container--fluid ">
        <div class="kt-subheader__main">
            <h3 class="kt-subheader__title">
                {if !empty($title_for_layout)}{$title_for_layout}{/if}
            </h3>
        </div>
    </div>
</div>

<div class="kt-container  kt-container--fluid  kt-grid__item kt-grid__item--fluid">
    <div class="kt-portlet nh-portlet">
        <div class="kt-portlet__body">
            <iframe style="min-height: 600px" frameborder="0" width="100%" height="100%" src="{CDN_URL}/filemanager/dialog.php?type=0&crossdomain=1&akey={$filemanager_access_key}&lang={LANGUAGE_ADMIN}">
            </iframe>
        </div>
    </div>
</div>