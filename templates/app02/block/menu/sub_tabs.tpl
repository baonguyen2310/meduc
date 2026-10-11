{assign var = number_column value = 2} {* column: 2 // 3 // 4 // 5 *}

{strip}
	<div nh-toggle-element="{$parent_menu_code}" class="entry-menu tabs-menu">
		<div class="container-menu">
			{foreach from = $data_sub_menu item = sub_menu key = k_0 name = tabs}
	            <div class="tabs-item {if !empty($sub_menu.children)}has-child{/if} {if $smarty.foreach.tabs.first}active{/if}">
	            	
					<a class="menu-link" href="{if !empty($sub_menu.url)}{$this->Utilities->checkInternalUrl($sub_menu.url)}{else}/{/if}">
						{$sub_menu.name|escape|truncate:60:" ..."}
						{if !empty($sub_menu.children)}
							<span class="child-indicator iconsax isax-arrow-right-3"></span>
						{/if}
					</a>

					{if !empty($sub_menu.children)}
						<span class="grower" nh-toggle="{$parent_menu_code}-{$k_0}"></span>
					{/if}

					<div nh-toggle-element="{$parent_menu_code}-{$k_0}" class="sub-menu">
						{if !empty($sub_menu.children)}

							{$sub_menu.children = array_chunk($sub_menu.children, $number_column)}
							{foreach from = $sub_menu.children key = k_1 item = item}
								<ul class="row-menu">
									{foreach from = $item key = k_2 item = sub_menu}

						                <li class="column-{$number_column} {if !empty($sub_menu.children)}has-child{/if}" >
											<a class="menu-title" href="{if !empty($sub_menu.url)}{$this->Utilities->checkInternalUrl($sub_menu.url)}{else}/{/if}">
												{$sub_menu.name|escape|truncate:60:" ..."}
											</a>

											{if !empty($sub_menu.children)}
												<span class="grower" nh-toggle="{$parent_menu_code}-{$k_1}-{$k_2}"></span>

												<ul nh-toggle-element="{$parent_menu_code}-{$k_1}-{$k_2}" class="sub-menu">
													{foreach from = $sub_menu.children item = sub_sub_menu}
														<li>
															<a class="menu-link" href="{if !empty($sub_sub_menu.url)}{$this->Utilities->checkInternalUrl($sub_sub_menu.url)}{else}/{/if}">
																{$sub_sub_menu.name|escape|truncate:60:" ..."}
															</a>
														</li>
													{/foreach}
												</ul>
											{/if}
										</li>
									{/foreach}
					            </ul>
					        {/foreach}

						{/if}
					</div>
				</div>
	        {/foreach}
	    </div>
	</div>
{/strip}