{strip}
{* Bottom shortcuts shown after scrolling. The text on the left comes from Admin > Settings > Website information. *}
{assign var = website_info value = $this->Setting->getWebsiteInfo()}
{include file='./catalog_navigation.tpl' scope=parent}

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
            {foreach from = $meduc_catalog_groups key = group_id item = group}
                <div class="mhb-menu-wrap" data-mhb-menu>
                    <button class="mhb-button mhb-button--primary" type="button" aria-expanded="false" aria-controls="mhb-{$group_id|escape}-menu">
                        <svg class="mhb-icon" aria-hidden="true"><use href="#mhi-icon-{$group.icon|escape}" /></svg>
                        <span>{$group.label|escape}</span>
                    </button>
                    <div class="mhb-menu" id="mhb-{$group_id|escape}-menu" hidden>
                        {foreach from = $group.items item = link}
                            <a class="mhb-button mhb-button--secondary" href="{$link.url|escape}">
                                <svg class="mhb-icon mhb-icon--always" aria-hidden="true"><use href="#mhi-icon-{$link.icon|escape}" /></svg>
                                <span>{$link.label|escape}</span>
                            </a>
                        {/foreach}
                    </div>
                </div>
            {/foreach}
            <div class="mhb-menu-wrap" data-mhb-menu>
                <button class="mhb-button mhb-button--primary" type="button" aria-expanded="false" aria-controls="mhb-gift-menu">
                    <svg class="mhb-icon mhb-icon--always" viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="8" width="18" height="4" rx="1"/><path d="M12 8v13M5 12v9h14v-9"/><path d="M12 8C10.5 5 7 4.5 7 7c0 1.5 2 1 5 1Zm0 0c1.5-3 5-3.5 5-1 0 1.5-2 1-5 1Z"/></svg>
                    <span>Quà tặng</span>
                </button>
                <div class="mhb-menu" id="mhb-gift-menu" hidden>
                    {foreach from = ['documents', 'blog', 'quiz'] item = gift_key}
                        {$link = $meduc_catalog_groups.library.items[$gift_key]}
                        <a class="mhb-button mhb-button--secondary" href="{$link.url|escape}">
                            <svg class="mhb-icon mhb-icon--always" aria-hidden="true"><use href="#mhi-icon-{$link.icon|escape}" /></svg>
                            <span>{$link.label|escape}</span>
                        </a>
                    {/foreach}
                </div>
            </div>
        </nav>
    </div>
</div>
{/strip}
