<div id="login-modal" class="modal fade" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-md modal-dialog-centered">
        <div class="modal-content bg-white shadow-box7 rounded-md">
			<div class="modal-header">
				<h3 class="modal-title fs-24">
					<b>{__d('template', 'dang_nhap')}</b>
				</h3>
				<button type="button" class="close icon-close" data-bs-dismiss="modal" aria-label="Close">
					<i class="iconsax isax-add"></i>
				</button>
			</div>
			<div class="modal-body">
				{$this->element('../Member/element_login_form')}
			</div>
        </div>   
    </div>
</div>