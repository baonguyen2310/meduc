{strip}
	<div nh-slidebar="notification" class="sidebar-mini-cart bg-white">
	    <div class="title-top-cart d-flex justify-content-between align-items-center mx-md-20 mt-10 mb-15">
	        <div class="title-cart fs-md-24 fs-17 font-weight-bold">
	            {__d('template', 'thong_bao_cua_ban')}
	        </div>
	    	<div class="sidebar-header">
	    		<a href="javascript:;" nh-slidebar-action="close" class="close-sidebar effect-rotate icon-close">
	    			<i class="iconsax isax-add"></i>
	    		</a>
	    	</div>
	    </div>

		<div class="content-mini-cart">
			<div class="box-minicart">
				<ul nh-list-notification class="cart-list list-unstyled mb-0">
					<li class="empty text-center py-30">
						<i class="iconsax isax-notification-bing"></i>
						<div class="empty-cart">
							{__d('template', 'ban_chua_co_thong_bao_nao')}
						</div>
					</li>
				</ul>
			</div>
		</div>
	</div>
{/strip}