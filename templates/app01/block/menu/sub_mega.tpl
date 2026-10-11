{assign var = number_column value = 4} {* column: 2 // 3 // 4 // 5 *}

{strip}
<ul nh-toggle-element="{$parent_menu_code}" class="entry-menu full-width">
	<li class="container-menu">
		{$data_sub_menu = array_chunk($data_sub_menu, $number_column)}
		{foreach from = $data_sub_menu key = k_0 item = item}
			<ul class="row-menu">
				{foreach from = $item key = k_1 item = sub_menu}
	            <li class="column-{$number_column} {if !empty($sub_menu.children)}has-child{/if}">
					<a class="menu-title" href="{if !empty($sub_menu.url)}{$this->Utilities->checkInternalUrl($sub_menu.url)}{else}/{/if}">
						{$sub_menu.name|escape|truncate:60:" ..."}
					</a>
					{if !empty($sub_menu.children)}

						<span class="grower" nh-toggle="{$parent_menu_code}-{$k_0}-{$k_1}"></span>
						<ul nh-toggle-element="{$parent_menu_code}-{$k_0}-{$k_1}" class="sub-menu">
							{foreach from = $sub_menu.children item = sub_sub_menu}
								<li>
									<a class="menu-link" href="{if !empty($sub_sub_menu.url)}{$this->Utilities->checkInternalUrl($sub_sub_menu.url)}{else}/{/if}">{$sub_sub_menu.name|escape|truncate:60:" ..."}</a>
								</li>
							{/foreach}
						</ul>
					{/if}
				</li>
				{/foreach}
	        </ul>
        {/foreach}
    </li>
</ul>
{/strip}