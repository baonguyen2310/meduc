{strip}
<div class="menu-container">
	<a class="btn-menu-mobile" nh-menu="btn-open" href="javascript:;">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
          <g id="Group_2" data-name="Group 2" transform="translate(-369 -12)">
            <rect id="Rectangle_2" data-name="Rectangle 2" width="24" height="24" transform="translate(369 12)" fill="#dbd09e" opacity="0"/>
            <g id="Group_1" data-name="Group 1">
              <rect id="Rectangle_3" data-name="Rectangle 3" width="11" height="3" rx="1.5" transform="translate(371 15)" fill="#dbd09e"/>
              <rect id="Rectangle_4" data-name="Rectangle 4" width="20" height="3" rx="1.5" transform="translate(371 23)" fill="#dbd09e"/>
              <rect id="Rectangle_5" data-name="Rectangle 5" width="11" height="3" rx="1.5" transform="translate(380 30)" fill="#dbd09e"/>
            </g>
          </g>
        </svg>

    </a>
    <div class="back-drop"></div>

	<nav class="menu-section" nh-menu="sidebar">
		<div class="menu-top">
			<span class="menu-header">Menu</span>
			<a href="javascript:;" nh-menu="btn-close" class="close-sidebar effect-rotate icon-close">
				<i class="iconsax isax-add"></i>
			</a>
		</div>

		{if !empty($data_block)}
			<ul>
				{foreach from = $data_block item = menu}
					{assign var = class_has_child value = ""}
					{if !empty($menu.has_sub_menu)}
						{assign var = class_has_child value = "has-child "}
					{/if}

					{assign var = class_position value = ""}
					{if !empty($menu.view_item) && $menu.view_item == 'sub_dropdown'}
						{assign var = class_position value = "position-relative "}
					{/if}

					{assign var = class_item value = ""}
					{if !empty($menu.class_item)}
						{assign var = class_item value = $menu.class_item}
					{/if}
					
					{if !empty($menu.name)}
						{assign var = image_source value = ''}
						{if !empty($menu.image) && !empty($menu.image_source)}
							{assign var = image_source value = $menu.image_source}
						{/if}

						{assign var = image_url value = ''}
						{if !empty($menu.image) && $image_source == 'cdn'}
							{assign var = image_url value = "{CDN_URL}{$menu.image}"}
						{/if}

						{if !empty($menu.image) && $image_source == 'template'}
							{assign var = image_url value = "{$menu.image}"}
						{/if}

						<li class="{$class_position}{$class_has_child}{$class_item}">
                            {if !empty($menu.image)}
                                <img src="{$image_url}" alt="{$menu.name}" class="marker-image" />
                            {/if}
							<a href="{if !empty($menu.url)}{$this->Utilities->checkInternalUrl($menu.url)}{else}/{/if}"
								{if !empty($menu.blank_link)}target="_blank"{/if}>
								{$menu.name|escape|truncate:60:" ..."}
								<span class="iconsax isax-arrow-down-1"></span>
							</a>

							{if empty($menu.data_sub_menu) && !empty($menu.data_extend_sub_menu)}
                                {$menu.data_sub_menu = $menu.data_extend_sub_menu}
                            {/if}

							{if !empty($menu.data_sub_menu)}							
								{assign var = parent_menu_code value = $this->Utilities->randomCode()}

								<span class="grower" nh-toggle="{$parent_menu_code}"></span>

								{$this->element("../block/{$block_type}/{$menu.view_item}", [
									'data_sub_menu' => $menu.data_sub_menu,
									'parent_menu_code' => $parent_menu_code
								])}
							{/if}
						</li>
					{/if}
				{/foreach}
			</ul>
		{/if}
	</nav>
</div>
{/strip}