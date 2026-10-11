"use strict";

var nhCustomer = function () {

	var formChangePassword;
	var formAccount;
	var formAccountStatus;
	var formStatusLearn;

	var initSubmit = function() {
		$(document).on('click', '.btn-password-save', function(e) {
			e.preventDefault();
			nhMain.initSubmitForm(formChangePassword, $(this));
		});

		$(document).on('click', '.btn-account-save', function(e) {
			e.preventDefault();
			nhMain.initSubmitForm(formAccount, $(this));
		});

		$(document).on('click', '.btn-account-status', function(e) {
			e.preventDefault();
			nhMain.initSubmitForm(formAccountStatus, $(this));
		});

		$(document).on('click', '.btn-status-learn', function(e) {
			e.preventDefault();
			nhMain.initSubmitForm(formStatusLearn, $(this));
		});
	}

	return {
		init: function() {
			formChangePassword = $('#change-pass');
			formAccount = $('#account-form');
			formAccountStatus = $('#account-status-form');
			formStatusLearn = $('#status-learn-form');
			initSubmit();
			$('.kt-selectpicker').selectpicker();


			$(document).on('click', '[nh-add-account]', function(e) {
				var customer_name = $(this).data('name');
				var customer_email = $(this).data('email').toLowerCase();
				var customer_code = $(this).data('code');

				if(formAccount == null || formAccount.length == 0) return;

				formAccount.find(`[name="full_name"]`).val(customer_name);
				formAccount.find(`[name="email"]`).val(customer_email);
				formAccount.find(`[name="username"]`).val(customer_email);
				formAccount.find(`[name="password"]`).val(customer_code);
			});

			// Paid
			$(document).on('click', '.change-price-special', function(e) {
				var _this = $(this);
				_this.popover({
					title: "Số tiền đã thanh toán",
					placement: 'right',
					html: true,
					sanitize: false,
					trigger: 'manual',
					content: $('#popover-price-special').html(),
					template: '\
						<div class="popover lg-popover" role="tooltip">\
								<div class="arrow"></div>\
								<h3 class="popover-header"></h3>\
								<div class="popover-body"></div>\
						</div>'
		    });

				var priceSpecial = $(this).closest('td').find('input[name="item_price_special"]').val();

				_this.popover('show');
				_this.on('shown.bs.popover', function (e) {		        	
					var idPopover = _this.attr('aria-describedby');
					var _popover = $('#' + idPopover);

					_popover.find('#price-special').val(priceSpecial);

					_popover.find('input.number-input').each(function() {
						nhMain.input.inputMask.init($(this), 'number');
					});
				})
			});

			$(document).on('click', '#confirm-special-price', function(e) {
				var _popover = $(this).closest('.popover.lg-popover');
				var idPopover = _popover.attr('id');
				var btnPopover = $('.change-price-special[aria-describedby="'+ idPopover +'"]');
				var priceSpecial = _popover.find('#price-special').val().replace(/,/g, "");

				btnPopover.closest('td').find('input[name="item_price_special"]').val(priceSpecial);
				btnPopover.closest('td').find('.price-special').text(priceSpecial);

				btnPopover.popover('dispose');

				const idRecord = btnPopover.attr("data-id");

				console.log(priceSpecial);
				nhMain.callAjax({
					async: true,
					url: adminPath + '/order/change-total-paid',
					data: {
						id: idRecord,
						total_paid: priceSpecial
					},
				}).done(function(response) {
					if(response.status == 200) {
						location.reload();
					}
				});
			});

			$(document).on('click', '#cancel-special-price', function(e) {
				var idPopover = $(this).closest('.popover.lg-popover').attr('id');
				var btnPopover = $('.change-price-special[aria-describedby="'+ idPopover +'"]');
				btnPopover.popover('dispose');
			});
			// End paid
		}
	};
}();

$(document).ready(function() {
	nhCustomer.init();
});
