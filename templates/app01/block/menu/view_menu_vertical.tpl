{strip}
{if !empty($data_block)}
    <div class="menu-cate-vertical">
        {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
            <div class="inner-title">
            	{$this->Block->getLocale('tieu_de', $data_extend)}
            </div>
        {/if}
        <ul>
        	{foreach from = $data_block item = menu}
        		{if !empty($menu.name)}
        			<li>
        				<a href="{if !empty($menu.url)}{$this->Utilities->checkInternalUrl($menu.url)}{else}/{/if}"
        					{if !empty($menu.blank_link)}target="_blank"{/if}>
        					{$menu.name|escape}
        				</a>
        			</li>
        		{/if}
        	{/foreach}
        </ul>
    </div>
{/if}
{/strip}