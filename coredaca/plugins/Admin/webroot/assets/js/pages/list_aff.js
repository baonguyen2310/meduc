"use strict";

var nhListCustomer = function() {
	var options = {
		data: {
			type: 'remote',
			source: {
				read: {
					url: adminPath + '/customer/aff/list/json',
					headers: {
						'X-CSRF-Token': csrfToken
					},
					map: function(raw) {
						var dataSet = raw;
						if (typeof raw.data !== _UNDEFINED) {
							dataSet = raw.data;
						}
						return dataSet;
					},
				},
			},
			pageSize: paginationLimitAdmin,
			serverPaging: true,
			serverFiltering: true,
			serverSorting: true,
		},
		
		layout: {
			scroll: false,
			footer: false,
			class: 'table-hover',
		},

		sortable: true,

		pagination: true,
		extensions: {
			checkbox: true
		},
		search: {
			input: $('#nh-keyword'),
		},

		translate: {
            records: {
                processing: nhMain.getLabel('vui_long_cho') +  ' ...',
                noRecords: nhMain.getLabel('khong_co_ban_ghi_nao'),
            }
        },

		columns: [
			{
				field: 'full_name',
				title: nhMain.getLabel('khach_hang'),
				width: 300,
				autoHide: false,
				template: function(row) {
					var name = typeof(row.full_name) != _UNDEFINED && row.full_name != null ? row.full_name : '';
					var email = typeof(row.email) != _UNDEFINED && row.email != null ? row.email : '';
					var phone = typeof(row.phone) != _UNDEFINED && row.phone != null ? row.phone : '';
					var code = typeof(row.code) != _UNDEFINED && row.code != null ? row.code : '';

					var urlEdit = adminPath + '/customer/aff/update/' + row.id;
					var urlDetail = adminPath + '/customer/aff/detail/' + row.id;
					return '\
						<div class="kt-user-card-v2 kt-user-card-v2--uncircle">\
							<div class="kt-user-card-v2__details lh-1-5">\
								<a href="'+ urlDetail +'" class="kt-user-card-v2__name">\
									<span class="kt-font-bolder">'+ nhMain.getLabel('ho_ten') +': </span>\
									'+ name +'\
								</a>\
								<p class="mb-0">\
									<span class="kt-font-bolder">'+ nhMain.getLabel('so_dien_thoai') +': </span>\
									'+ phone +'\
								</p>\
								<p class="mb-0">\
									<span class="kt-font-bolder">'+ nhMain.getLabel('email') +': </span>\
									'+ email +'\
								</p>\
								<p class="mb-0">\
									<span class="kt-font-bolder">Mã đối tác: </span>\
									'+ code +'\
								</p>\
							</div>\
						</div>';
				}
			},
			
			{
				field: 'bank',
				title: "Tài khoản ngân hàng",
				autoHide: false,
				template: function(row) {
				    console.log(row);
					let affiliate_amount = 0;
					let affiliate_amount_unpaid = 0;
					let affiliate_amount_paid = 0;
					
					if(row.affiliate_amount != null) {
					    affiliate_amount = parseFloat(row.affiliate_amount);
					    affiliate_amount = nhMain.utilities.parseNumberToTextMoney(affiliate_amount);
					};
					
					if(row.affiliate_amount_unpaid != null) {
					    affiliate_amount_unpaid = parseFloat(row.affiliate_amount_unpaid);
					    affiliate_amount_paid = row.affiliate_amount - row.affiliate_amount_unpaid;
					    affiliate_amount_unpaid = nhMain.utilities.parseNumberToTextMoney(affiliate_amount_unpaid);
					    affiliate_amount_paid = nhMain.utilities.parseNumberToTextMoney(affiliate_amount_paid);
					};
					
					return `
						<div>Tên ngân hàng: <strong>${row.bank_name || ""}</strong></div>
						<div>Chủ tài khoản: <strong>${row.bank_fullname || ""}</strong></div>
						<div>Số tài khoản: <strong>${row.bank_number || ""}</strong></div>
					`;
				},
			},
			
			{
				field: 'affiliate',
				title: "Hoa hồng",
				autoHide: false,
				template: function(row) {
					let affiliate_amount = 0;
					let affiliate_amount_unpaid = 0;
					let affiliate_amount_paid = 0;
					
					if(row.affiliate_amount != null) {
					    affiliate_amount = parseFloat(row.affiliate_amount);
					    affiliate_amount = nhMain.utilities.parseNumberToTextMoney(affiliate_amount);
					};
					
					if(row.affiliate_amount_unpaid != null) {
					    affiliate_amount_unpaid = parseFloat(row.affiliate_amount_unpaid);
					    affiliate_amount_paid = row.affiliate_amount - row.affiliate_amount_unpaid;
					    affiliate_amount_unpaid = nhMain.utilities.parseNumberToTextMoney(affiliate_amount_unpaid);
					    affiliate_amount_paid = nhMain.utilities.parseNumberToTextMoney(affiliate_amount_paid);
					};
					
					return `
						<div>Tổng hoa hồng: <strong>${affiliate_amount}đ</strong></div>
						<div>Hoa hồng chưa thanh toán: <strong>${affiliate_amount_unpaid}đ</strong></div>
						<div>Hoa hồng đã thanh toán: <strong>${affiliate_amount_paid}đ</strong></div>
					`;
				},
			},
			
			{
				field: 'action',
				title: "Hành động",
				autoHide: false,
				template: function(row) {
				    var urlDetail = adminPath + '/customer/aff/detail/' + row.id;
				    
					return `
					    <a href="${urlDetail}" class="btn btn-sm btn-info">
							Xem chi tiết
						</a>
					`;
				},
			},
		]
	}

	return {
		listData: function() {
			$('.number-input').each(function() {
				nhMain.input.inputMask.init($(this), 'number');
			});

			var datatable = $('.kt-datatable').KTDatatable(options);

			$('#nh_phone').on('keyup', function() {
		      	datatable.search($(this).val(), 'phone');
		    });

			$('#nh_status').on('change', function() {
		      	datatable.search($(this).val(), 'status');
		    });
			
		    // event delete and change status on list
		    nhList.eventDefault(datatable, {
		    	url: {
			    	delete: adminPath + '/customer/aff/delete',
			    	status: adminPath + '/customer/aff/change-status',
			    	quickChange: adminPath + '/customer/aff/quick-change',
			    }
		    });

		    // add account
	      	var formAccount = $('#account-form');
	      	var formAccountStatus = $('#account-status-form');

	    	$(document).on('click', '[nh-add-account]', function(e) {
		      	var customer_id = $(this).data('id');
		      	var customer_name = $(this).data('name');
		      	var customer_email = $(this).data('email').toLowerCase();
		      	var customer_code = $(this).data('code');

		      	if(typeof(customer_id) == _UNDEFINED || customer_id == '') return;
		      	if(formAccount == null || formAccount.length == 0) return;

		      	formAccount.attr('action', '/admin/customer/aff/add-account/' + customer_id);
		      	formAccount.find(`[name="full_name"]`).val(customer_name);
		      	formAccount.find(`[name="email"]`).val(customer_email);
		      	formAccount.find(`[name="username"]`).val(customer_email);
		      	formAccount.find(`[name="password"]`).val(customer_code);
		    });

		    $(document).on('click', '[nh-active-account]', function(e) {
		      	var customer_id = $(this).data('id');

		      	if(typeof(customer_id) == _UNDEFINED || customer_id == '') return;
		      	if(formAccountStatus == null || formAccountStatus.length == 0) return;

		      	formAccountStatus.attr('action', '/admin/customer/aff/account-status/' + customer_id);
		    });

		    $(document).on('click', '.btn-account-save', function(e) {
				e.preventDefault();
				if(formAccount == null || formAccount.length == 0) return;

				nhMain.initSubmitForm(formAccount, $(this));
			});

			$(document).on('click', '.btn-account-status', function(e) {
				e.preventDefault();
				nhMain.initSubmitForm(formAccountStatus, $(this));
			});

		  $('.kt-selectpicker').selectpicker();
		}
	};
}();

jQuery(document).ready(function() {
	nhListCustomer.listData();
});