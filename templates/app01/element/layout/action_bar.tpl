{strip}
{* Bottom action bar, after MasterClass's sticky "Get MasterClass" bar. It slides in once the page has scrolled a little.
   The text on the left comes from Admin > Settings > Website information. *}
{assign var = website_info value = $this->Setting->getWebsiteInfo()}

<div class="mhb" id="meduc-action-bar">
    <div class="mhb-shell">
        <div class="mhb-info">
            {if !empty($website_info.website_name)}
                <p class="mhb-title">{$website_info.website_name|escape}</p>
            {/if}
            {if !empty($website_info.hotline)}
                <a class="mhb-hotline" href="tel:{$website_info.hotline|escape}">Hotline {$website_info.hotline|escape}</a>
            {/if}
        </div>
        <nav class="mhb-actions" aria-label="Lối tắt MedUC">
            <a class="mhb-button mhb-button--primary" href="/danh-sach-de-thi">
                <svg class="mhb-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M9 4h6v3H9z"/><path d="M9 5.5H6V21h12V5.5h-3"/><path d="m9 14 2 2 4-4"/></svg>
                <span>Luyện thi</span>
            </a>
            <a class="mhb-button mhb-button--primary" href="/khoa-hoc">
                <svg class="mhb-icon" viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="m10 9 5 3-5 3z"/></svg>
                <span>Khoá học</span>
            </a>
            <a class="mhb-button mhb-button--secondary" href="/sach-y-khoa">
                <svg class="mhb-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M12 5v16M12 5C8 3 5 3 2 4v15c3-1 6-1 10 2 4-3 7-3 10-2V4c-3-1-6-1-10 1Z"/></svg>
                <span>Sách</span>
            </a>
            <div class="mhb-gift">
                <button class="mhb-button mhb-button--outline" type="button" aria-expanded="false" aria-controls="mhb-gift-menu">
                    <svg class="mhb-icon mhb-icon--always" viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="8" width="18" height="4" rx="1"/><path d="M12 8v13M5 12v9h14v-9"/><path d="M12 8C10.5 5 7 4.5 7 7c0 1.5 2 1 5 1Zm0 0c1.5-3 5-3.5 5-1 0 1.5-2 1-5 1Z"/></svg>
                    <span>Quà tặng</span>
                </button>
                <div class="mhb-gift-menu" id="mhb-gift-menu" hidden>
                    <a class="mhb-button mhb-button--secondary" href="/tai-lieu-hoc-tap">
                        <svg class="mhb-icon mhb-icon--always" viewBox="0 0 24 24" aria-hidden="true"><path d="M14 3H6v18h12V7z"/><path d="M14 3v4h4M9 12h6M9 16h6"/></svg>
                        <span>Tài liệu</span>
                    </a>
                    <a class="mhb-button mhb-button--secondary" href="/blog">
                        <svg class="mhb-icon mhb-icon--always" viewBox="0 0 24 24" aria-hidden="true"><path d="M4 20h4L19 9l-4-4L4 16z"/><path d="m13 7 4 4"/></svg>
                        <span>Blog</span>
                    </a>
                </div>
            </div>
        </nav>
    </div>
</div>
{/strip}
