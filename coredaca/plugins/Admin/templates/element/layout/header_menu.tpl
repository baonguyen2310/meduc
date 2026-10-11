<!-- Uncomment this to display the close button of the panel
<button class="kt-header-menu-wrapper-close" id="kt_header_menu_mobile_close_btn"><i class="la la-close"></i></button>
-->

{assign var = website_info value = $this->SettingAdmin->getWebsiteInfo($lang)}

<div class="kt-header-menu-wrapper" id="kt_header_menu_wrapper">
	<div id="kt_header_menu" class="kt-header-menu kt-header-menu-mobile  kt-header-menu--layout-default ">
		<ul class="kt-menu__nav ">
			<li class="kt-menu__item  kt-menu__item--submenu kt-menu__item--rel kt-menu__item--active">
				<h4>
					<a href="/" target="_blank" class="kt-font-dark">
						{if !empty($website_info.website_name)}
							{$website_info.website_name}
						{/if}
					</a>
				</h4>
			</li>
		</ul>
	</div>
</div>