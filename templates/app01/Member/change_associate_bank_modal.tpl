<div id="change-associate-bank-modal" class="modal fade" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-md modal-dialog-centered">
        <div class="modal-content">
			<div class="modal-header px-15">
				<h3 class="modal-title font-weight-bold color-black text-uppercase fs-20">{__d('template', 'lien_ket_ngan_hang')}</h3>
				<button type="button" class="close effect-rotate icon-close" data-dismiss="modal" aria-label="Close">
					<i class="iconsax isax-add"></i>
				</button>
			</div>
			<div class="modal-body px-15">
				{$this->element('../Member/element_associate_bank_form')}
			</div>

        </div>   
    </div>
</div>