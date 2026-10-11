{strip}
<div nh-mini-cart="sidebar" class="sidebar-mini-cart">
    <div class="title-top-cart d-flex  justify-content-between align-items-center mx-10">
        <div class="title-cart fs-16 fw-bold">
            	{__d('template', 'gio_hang_cua_ban')}
        </div>
    	<div class="sidebar-header">
    		<a href="javascript:;" nh-mini-cart="close" class="close-sidebar effect-rotate icon-close">
    			<i class="iconsax isax-add"></i>
    		</a>
    	</div>
    </div>
	<div class="content-mini-cart">
		<div class="box-minicart" nh-total-quantity-cart="0">
			<ul class="cart-list list-unstyled mb-0">
				<li class="empty text-center py-30">
					<i class="iconsax isax-bag-cross-1"></i>
					<div class="empty-cart">
						{__d('template', 'chua_co_san_pham_nao_trong_gio_hang')}
					</div>
				</li>
			</ul>
		</div>
	</div>
</div>
{/strip}