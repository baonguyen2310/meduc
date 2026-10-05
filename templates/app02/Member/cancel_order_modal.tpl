<div id="cancel-order-modal" class="modal fade" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-md">
        <div class="modal-content shadow-modal">
			<div class="modal-header">
				<h3 class="modal-title">{__d('template', 'xac_nhan_huy_don_hang')}</h3>
				<button type="button" class="close icon-close" data-dismiss="modal" aria-label="Close">
					<i class="iconsax isax-add"></i>
				</button>
			</div>
			<div class="modal-body">                   
                <textarea name="note" placeholder="{__d('template', 'ly_do_huy_don')}"></textarea>
                <input type="hidden" value="" name="order_id">
			</div>
			<div class="modal-footer">
				<button nh-confirm class="btn btn-sm btn-secondary btn-confirm text-uppercase">
					{__d('template', 'dong_y')}
				</button>
			</div>
        </div>   
    </div>
</div>