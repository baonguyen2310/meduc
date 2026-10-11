<div id="change-address-modal" class="modal fade" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered">
        <div class="modal-content">
			<div class="modal-header px-30">
				<h3 class="modal-title font-weight-bold color-black text-uppercase">{__d('template', 'dia_chi_nhan_hang')}</h3>
				<button type="button" class="close effect-rotate icon-close" data-dismiss="modal" aria-label="Close">
					<i class="iconsax isax-add"></i>
				</button>
			</div>
			<div class="modal-body px-30">
				{$this->element('../Member/element_address_form')}
			</div>

        </div>   
    </div>
</div>