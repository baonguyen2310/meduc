"use strict";

var nhListCustomer = function() {
	var options = {
		data: {
			type: 'remote',
			source: {
				read: {
					url: adminPath + '/customer/list/json',
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

					var urlEdit = adminPath + '/customer/update/' + row.id;
					var urlDetail = adminPath + '/customer/detail/' + row.id;
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
									<span class="kt-font-bolder">'+ nhMain.getLabel('ma_khach_hang') +': </span>\
									'+ code +'\
								</p>\
							</div>\
						</div>';
				}
			},
			{
				field: 'username',
				title: nhMain.getLabel('tai_khoan'),
				width: 200,
				sortable: false,
				template: function(row) {
					var status_account = KTUtil.isset(row, 'account_status') && row.account_status != null ? row.account_status : null;
					var username = typeof(row.username) != _UNDEFINED && row.username != null ? row.username : '';

					var _htmlAccount = '<span class="text-danger">'+ nhMain.getLabel('chua_thiet_lap') +'</span>';

					if (typeof(row.username) != _UNDEFINED && row.username != null && status_account == 2) {
						_htmlAccount = '<span class="text-warning">'+ username +'</span>';
					}

					if (typeof(row.username) != _UNDEFINED && row.username != null && status_account == 1) {
						_htmlAccount = '<span class="text-success">'+ username +'</span>';
					}


					return _htmlAccount;
				}
			},
			{
				field: 'orders_info',
				title: "Thông tin thanh toán",
				autoHide: false,
				template: function(row) {
					let total = 0;
					let total_paid = 0;
					let total_unpaid = 0;
					if(row.orders_info != null) {
						row.orders_info.forEach(item => {
							total = total + parseInt(item.total);
							total_paid = total_paid + parseInt(item.total_paid);
						});
						total_unpaid = total - total_paid;
					};
					total = nhMain.utilities.parseNumberToTextMoney(total);
					total_paid = nhMain.utilities.parseNumberToTextMoney(total_paid);
					total_unpaid = nhMain.utilities.parseNumberToTextMoney(total_unpaid);
					return `
						<div>Tổng tiền: <strong>${total}đ</strong></div>
						<div>Đã đóng: <strong class="text-success">${total_paid}đ</strong></div>
						<div>Còn lại: <strong class="text-danger">${total_unpaid}đ</strong></div>
					`;
				},
			},
			{
				field: 'status_learn',
				title: "Trạng thái học",
				autoHide: false,
				template: function(row) {
					console.log(row);
					let string = "";
					let color = "";
					switch (row.status_learn) {
						case "danghoc":
							string = "Đang học";
							color = "info";
							break;
						case "baoluu":
							string = "Bảo lưu";
							color = "warning";
							break;
						case "nghihoc":
							string = "Nghỉ học";
							color = "danger";
							break;
						case "hoanthanh":
							string = "Hoàn thành";
							color = "success";
							break;
						default:
							string = "Chưa thiết lập";
							color = "dark";
							break;
					}
					return `
						<span class="kt-badge  kt-badge--${color} kt-font-bold kt-badge--inline kt-badge--pill">${string}</span>
					`;
				},
			},
			// {
			// 	field: 'full_address',
			// 	title: nhMain.getLabel('dia_chi'),
			// 	sortable: false
			// },
			{
				field: 'status',
				title: "Trạng thái tài khoản",				
				width: 110,
				autoHide: false,
				template: function(row) {
					var status = '';
					if(KTUtil.isset(row, 'status') && row.status != null){
						status = nhList.template.status(row.status);
					}
					return status;					
				},
			},
			// {
			// 	field: 'course',
			// 	title: "Thêm vào lớp",				
			// 	width: 110,
			// 	autoHide: false,
			// 	template: function(row) {
			// 		var course = '';
			// 		if(row.course == "1"){
			// 			course = `<span class="kt-badge  kt-badge--success kt-font-bold kt-badge--inline kt-badge--pill">Được học</span>`;
			// 		} else {
			// 			course = `<span class="kt-badge  kt-badge--danger kt-font-bold kt-badge--inline kt-badge--pill">Không được học</span>`;
			// 		}
			// 		return course;					
			// 	},
			// },
			// {
			// 	field: 'send_email',
			// 	title: "Nhắc đóng tiền",				
			// 	width: 110,
			// 	autoHide: false,
			// 	template: function(row) {
			// 		console.log(row);
			// 		var button = '';
			// 		var name = typeof(row.full_name) != _UNDEFINED && row.full_name != null ? row.full_name : '';
			// 		var email = typeof(row.email) != _UNDEFINED && row.email != null ? row.email : '';
			// 		var btnClass = 'btn-brand';
			// 		var btnText = 'Gửi Email';
			// 		if(row.reminded == 1){
			// 			btnClass = 'btn-success';
			// 			btnText = 'Gửi Lại Email';
			// 		}

			// 		if(!KTUtil.isset(row, 'account_id') && row.account_id == null){
			// 			button = `
			// 				<form id="form-send-email-remind-${row.id}" class="form-send-email-remind" action="/admin/customer/send-email-remind" method="POST" autocomplete="off" >
			// 						<div class="modal-body d-none">
			// 							<div class="form-group">
			// 								<input name="id" value="${row.id}" class="form-control form-control-sm" type="number">
			// 							</div>
			// 							<div class="form-group">
			// 								<input name="full_name" value="${name}" class="form-control form-control-sm" type="text">
			// 							</div>
			// 							<div class="form-group">
			// 								<input name="email" value="${email}" class="form-control form-control-sm" type="text">
			// 							</div>
			// 						</div>
			// 						<button type="button" class="btn btn-sm ${btnClass} btn-send-email-remind">${btnText}</button>
			// 				</form>
			// 			`;
			// 		}
			// 		setTimeout(function() {
			// 			var form = $(`#form-send-email-remind-${row.id}`);
			// 			form.on('click', '.btn-send-email-remind', function(e) {
			// 				e.preventDefault();
			// 				nhMain.initSubmitForm(form, $(this));
			// 			});
			// 		}, 1000);
			// 		return `${button}`;
			// 	},
			// },
			{
				field: 'action',
				title: '',
				width: 30,
				autoHide: false,
				sortable: false,
				template: function(row){
					var _htmlAddAccount = '';
					var name = typeof(row.full_name) != _UNDEFINED && row.full_name != null ? row.full_name : '';
					var email = typeof(row.email) != _UNDEFINED && row.email != null ? row.email : '';
					var code = typeof(row.code) != _UNDEFINED && row.code != null ? row.code : '';

					if(!KTUtil.isset(row, 'account_id') && row.account_id == null){
						_htmlAddAccount = '\
						<a class="dropdown-item" nh-add-account href="javascript:;" data-id="'+ row.id +'" data-toggle="modal" data-target="#modal-add-account" data-name="'+name+'" data-email="'+email+'" data-code="'+code+'">\
							<span class="text-primary"><i class="fas fa-user-plus fs-14 mr-10"></i>'
								+ nhMain.getLabel('them_tai_khoan') +
							'</span>\
						</a>';
					}

					if(KTUtil.isset(row, 'account_id') && row.account_id != null && row.account_status == 2){
						_htmlAddAccount = '\
						<a class="dropdown-item" nh-active-account href="javascript:;" data-id="'+ row.id +'" data-toggle="modal" data-target="#modal-account-status">\
							<span class="text-success"><i class="fas fa-user-plus fs-14 mr-10"></i>'
								+ nhMain.getLabel('kich_hoat_tai_khoan') +
							'</span>\
						</a>';
					}

					return '\
					<div class="dropdown dropdown-inline">\
						<button type="button" class="btn btn-clean btn-icon btn-sm btn-icon-md" data-toggle="dropdown">\
							<i class="flaticon-more"></i>\
						</button>\
						<div class="dropdown-menu dropdown-menu-right pt-5 pb-5">\
							<a class="dropdown-item" href="' + adminPath + '/customer/detail/' + row.id + '">\
								<span class="text-primary"><i class="fas fa-eye fs-14 mr-10"></i>'
									+ nhMain.getLabel('xem_thong_tin') +
								'</span>\
							</a>\
							' + _htmlAddAccount + '\
							<a class="dropdown-item nh-change-status" href="javascript:;" data-id="'+ row.id +'" data-status="1">\
								<span class="text-success"><i class="fas fa-check-circle fs-14 mr-10"></i>'
									+ nhMain.getLabel('hoat_dong') +
								'</span>\
							</a>\
							<a class="dropdown-item nh-change-status" href="javascript:;" data-id="'+ row.id +'" data-status="0">\
								<span class="text-warning"><i class="fas fa-times-circle fs-14 mr-10"></i>'
									+ nhMain.getLabel('ngung_hoat_dong') +
								'</span>\
							</a>\
							<a class="dropdown-item nh-delete" href="javascript:;" data-id="'+ row.id +'">\
								<span class="text-danger"><i class="fas fa-trash-alt fs-14 mr-10"></i>'
									+ nhMain.getLabel('xoa') +
								'</span>\
							</a>\
						</div>\
					</div>';
				}
			}
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
			    	delete: adminPath + '/customer/delete',
			    	status: adminPath + '/customer/change-status',
			    	quickChange: adminPath + '/customer/quick-change',
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

		      	formAccount.attr('action', '/admin/customer/add-account/' + customer_id);
		      	formAccount.find(`[name="full_name"]`).val(customer_name);
		      	formAccount.find(`[name="email"]`).val(customer_email);
		      	formAccount.find(`[name="username"]`).val(customer_email);
		      	formAccount.find(`[name="password"]`).val(customer_code);
		    });

		    $(document).on('click', '[nh-active-account]', function(e) {
		      	var customer_id = $(this).data('id');

		      	if(typeof(customer_id) == _UNDEFINED || customer_id == '') return;
		      	if(formAccountStatus == null || formAccountStatus.length == 0) return;

		      	formAccountStatus.attr('action', '/admin/customer/account-status/' + customer_id);
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

			// Send Email Remind
			// setTimeout(function() {
			// 	$('.form-send-email-remind').each(function() {
			// 		var form = $(this);
			// 		$(this).on('click', '.btn-send-email-remind', function(e) {
			// 			e.preventDefault();
			// 			nhMain.initSubmitForm(form, $(this));
			// 		});
			// 	});
			// }, 1000);

		  $('.kt-selectpicker').selectpicker();
		}
	};
}();

jQuery(document).ready(function() {
	nhListCustomer.listData();
});