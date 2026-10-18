{strip}
{* Shared portraits for the homepage rail and the faculty directory. Profile mode opens the dossier instead of a course. *}
{foreach from = $data_block item = item key = index}
    {$full_name = $item.name|default:''|trim}
    {if $full_name == ''}{continue}{/if}
    {$display_name = $full_name|regex_replace:'/\s*\([^()]*\)\s*$/u':''|regex_replace:'/\s+/u':' '}
    {$subject = 'Giảng viên MedUC'}
    {if !empty($item.description_short)}
        {$subject = $item.description_short|trim}
    {elseif preg_match('/\([^()]*\)\s*$/u', $full_name)}
        {$subject = $full_name|regex_replace:'/^.*\(\s*([^()]*?)\s*\)\s*$/us':'$1'|regex_replace:'/^Dạy\s+/iu':''}
    {/if}
    {$description = $item.description|default:''|regex_replace:'/^[\s\-\/]+/u':''|regex_replace:'/\s*[\r\n]+[\s\-\/]*/u':' · '|regex_replace:'/[\s·]+$/u':''}
    {$course_url = $item.url|default:''|trim}
    {$href = $team_url|default:'/doi-ngu-giang-vien'}
    {if $course_url != ''}{$href = $course_url}{/if}
    {$photo = ''}
    {if !empty($item.image)}
        {if $item.image_source == 'cdn'}
            {$photo = "{CDN_URL}{$this->Utilities->getThumbs($item.image, 720)}"}
        {else}
            {$photo = $item.image}
        {/if}
    {/if}
    <article class="mgv-card{if $course_url == ''} mgv-card--centered{/if}{if !empty($item.class_item)} {$item.class_item|escape}{/if}">
        {if !empty($profile_mode)}
            <div class="mgv-photo">{if $photo != ''}<img src="{$photo|escape}" alt="Chân dung {$display_name|escape}" loading="lazy" decoding="async" />{/if}</div>
        {else}
            <a class="mgv-photo" href="{$href|escape}" aria-label="Tìm hiểu về {$display_name|escape}">{if $photo != ''}<img src="{$photo|escape}" alt="Chân dung {$display_name|escape}" loading="lazy" decoding="async" />{/if}</a>
        {/if}
        <span class="mgv-subject">{$subject|escape}</span>
        <div class="mgv-copy">
            <h3 class="mgv-name">{if !empty($profile_mode)}{$display_name|escape}{else}<a href="{$href|escape}">{$display_name|escape}</a>{/if}</h3>
            <p class="mgv-description">
                {if !empty($profile_mode) && !empty($item.description)}
                    {foreach from = preg_split('/[\r\n]+/u', $item.description) item = line}
                        {$line = $line|regex_replace:'/^[\s\-\/]+/u':''|trim}
                        {if $line != ''}<span class="mft-description-line">{$line|escape}</span>{/if}
                    {/foreach}
                {else}{$description|escape}{/if}
            </p>
            {if !empty($profile_mode)}
                <span class="mgv-cta">Xem hồ sơ &amp; bằng cấp</span>
            {else}
                <a class="mgv-cta" href="{$href|escape}">{if $course_url != ''}Tìm hiểu khóa học{else}Tìm hiểu đội ngũ{/if}</a>
            {/if}
        </div>
        {if !empty($profile_mode)}
            <div class="mft-list-action" aria-hidden="true"><span class="mft-list-action-label">BẰNG CẤP &amp; CHUYÊN MÔN</span><span class="mft-list-cta">Xem hồ sơ <span>→</span></span></div>
            <button class="mft-open-profile" type="button" data-faculty-open="mft-profile-{$index}" aria-label="Xem hồ sơ và bằng cấp của {$display_name|escape}" aria-haspopup="dialog"></button>
        {/if}
    </article>
    {if !empty($profile_mode)}
        <template id="mft-profile-{$index}">
            <div class="mft-dossier-photo{if $course_url == ''} mft-dossier-photo--centered{/if}">
                {if $photo != ''}<img src="{$photo|escape}" alt="Chân dung {$display_name|escape}" />{/if}
                <span>MEDUC / ĐỘI NGŨ</span>
            </div>
            <div class="mft-dossier-content">
                <p class="mft-kicker">{$subject|escape}</p>
                <h2 id="mft-profile-title">{$display_name|escape}</h2>
                {if !empty($item.description)}
                    <section class="mft-dossier-section">
                        <h3>Chuyên môn &amp; kinh nghiệm</h3>
                        <ul>
                            {foreach from = preg_split('/[\r\n]+/u', $item.description) item = line}
                                {$line = $line|regex_replace:'/^[\s\-\/]+/u':''|trim}
                                {if $line != ''}<li>{$line|escape}</li>{/if}
                            {/foreach}
                        </ul>
                    </section>
                {/if}
                <section class="mft-dossier-section">
                    <h3>Bằng cấp &amp; chứng chỉ</h3>
                    {if !empty($item.faculty_credentials)}
                        <div class="mft-credentials">
                            {foreach from = $item.faculty_credentials item = credential}
                                {$credential_url = $credential.url}
                                {if $credential.source == 'cdn'}{$credential_url = "{CDN_URL}{$credential.url}"}{/if}
                                <figure>
                                    {if !$credential.is_pdf}<img src="{$credential_url|escape}" alt="{$credential.title|escape}" loading="lazy" />{/if}
                                    <figcaption><span>{$credential.title|escape}</span><a href="{$credential_url|escape}" target="_blank" rel="noopener">{if $credential.is_pdf}Xem PDF{else}Xem ảnh gốc{/if} <span aria-hidden="true">↗</span></a></figcaption>
                                </figure>
                            {/foreach}
                        </div>
                    {else}
                        <p class="mft-credentials-pending">Ảnh bằng cấp và chứng chỉ sẽ được MedUC bổ sung vào hồ sơ này.</p>
                    {/if}
                </section>
                {if $course_url != ''}<a class="mft-button mft-button--primary" href="{$course_url|escape}">Học thử miễn phí <span aria-hidden="true">→</span></a>{/if}
            </div>
        </template>
    {/if}
{/foreach}
{/strip}
