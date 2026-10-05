<div id="login-modal" class="modal fade" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-md modal-dialog-centered">
        <div class="modal-content shadow-modal">
			<div class="modal-header">
				<h3 class="modal-title text-uppercase">
					<b>{__d('template', 'dang_nhap')}</b>
				</h3>
				<button type="button" class="close icon-close" data-dismiss="modal" aria-label="Close">
					<i class="iconsax isax-add"></i>
				</button>
			</div>
			<div class="modal-body">
				{$this->element('../Member/element_login_form')}
			</div>
        </div>   
    </div>
</div>