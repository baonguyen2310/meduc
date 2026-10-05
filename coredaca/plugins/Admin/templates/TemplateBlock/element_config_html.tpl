{assign var = filemanager_access_key_template value = $this->SystemAdmin->getAccessKeyUploadToTemplate()}
{assign var = filemanager_access_key value = $this->SystemAdmin->getAccessKeyUpload()}

<div class="kt-separator kt-separator--space-lg kt-separator--border-solid mt-10"></div>

<div class="form-group">
    {*<span btn-select-media-block="template" action="copy" data-src="/filemanager/dialog.php?akey={$filemanager_access_key_template}&field_id=image_template&lang={$lang}" data-type="iframe" class="btn btn-sm btn-success">
        <i class="fa fa-images"></i>
        {__d('admin', 'chon_anh_giao_dien')}
    </span>
    <input id="image_template" type="hidden" value="">*}
    
    <span btn-select-media-block="cdn" action="copy" data-src="{CDN_URL}/filemanager/dialog.php?crossdomain=1&akey={$filemanager_access_key}&field_id=image_block&lang={$lang}" data-type="iframe" class="btn btn-sm btn-brand">
        <i class="fa fa-photo-video"></i>
        {__d('admin', 'chon_anh_tu_cdn')}
    </span>
</div>


<div class="row">
    <div class="col-lg-12 col-12">
        <div class="form-group">
            <label>
                HTML
            </label>
            <div class="clearfix">
                <div id="editor-html" class="nh-editor"></div>
                <input id="html-content" name="config[html_content]" value="{if !empty($config.html_content)}{htmlentities($config.html_content)}{/if}" type="hidden">
            </div>
        </div>
    </div>
</div>