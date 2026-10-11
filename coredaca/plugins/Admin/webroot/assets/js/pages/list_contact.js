"use strict";

var nhListContact = function() {
	const urlParams = new URLSearchParams(window.location.search);
	const contactId = urlParams.get("contact");

	if(contactId == "6") {
		var options = {
			data: {
				type: 'remote',
				source: {
					read: {
						url: adminPath + '/contact/list/json',
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
	
			data_filter: {
				lang: nhMain.lang,
				keyword: $('#nh-keyword').val(),
				status: $('#nh-status').val(),
				form_id: contactId || $('#form_id').val(),
				create_from: $('#create_from').val(),
				create_from: $('#create_from').val()
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
					field: 'form_name',
					title: "Mã đơn hàng",
					sortable: false,
					width: 130,
					template: function(row){
						var content = KTUtil.isset(row, 'content') && row.content != null ? row.content : [];
						var cardId = content["Mã đơn hàng"];

						var result = `
							<div class="code-time nh-weight">
								<div>
									<i class="fas fa-qrcode"></i>
									<a href="${adminPath}/contact/detail/${row.id}">
										${cardId}
									</a>
								</div>
								<div>
									<i class="far fa-clock"></i>
									${row.created}
								</div>					
							</div>
						`;

						return result;
					}
				},

				{
					field: 'content',
					title: "Thông tin khách hàng",
					sortable: false,
					template: function(row){
						var content = KTUtil.isset(row, 'content') && row.content != null ? row.content : [];
						var fullName = content["Họ tên"];
						var phone = content["Số điện thoại"];
						var email = content["Email"];
						var address = content["Địa chỉ nhận hàng"];

						var result = `
							<p class="mb-5">Họ tên: <strong>${fullName}</strong></p>
							<p class="mb-5">SĐT: <strong>${phone}</strong></p>
							<p class="mb-5">Email: <strong>${email}</strong></p>
							<p class="mb-5">Địa chỉ: <strong>${address}</strong></p>
						`;
	
						return result;
					}
				},

				{
					field: 'quantity',
					title: "Số lượng",
					sortable: false,
					width: 60,
					template: function(row){	
						var content = KTUtil.isset(row, 'content') && row.content != null ? row.content : [];
						var result = `${content.totalQuantity}`;
						return result;
					}
				},
				
				{
					field: 'affiliate',
					title: "Affiliate",
					sortable: false,
					width: 170,
					template: function(row){
						var result = "";
						if(row.value.affiliateCode) {
						    result = `
						        Mã giới thiệu: <b>${row.value.affiliateCode}</b>
						        <br />
						        Hoa hồng: <b>${row.value.affiliateAmount.toLocaleString()} VND</b>
					            <br />
						        % Hoa hồng: <b>${row.value.affiliatePercent}%</b>
						    `;
						    
						    var status = '';
    						var statusOptions = {
    							initial: {'title': "Khởi tạo", 'class': 'kt-badge--dark kt-font-bold'},
    							success: {'title': "Đã duyệt", 'class': 'kt-badge--success kt-font-bold'},
    							cancel: {'title': "Đã hủy", 'class': 'kt-badge--danger kt-font-bold'},
    						};
    						if(row.value.orderStatus){
    							status = '<span class="kt-badge ' + statusOptions[row.value.orderStatus].class + ' kt-badge--inline kt-badge--pill">' + statusOptions[row.value.orderStatus].title + '</span>';
    						}
    						result += `
						        <br />
    						    Trạng thái: ${status}
    						`;
						}
						
						return result;
					}
				},

				{
					field: 'total',
					title: "Tổng tiền",
					sortable: false,
					width: 110,
					template: function(row){	
				// 		var content = KTUtil.isset(row, 'content') && row.content != null ? row.content : [];
						
						var result = ``;
						var total = row.value.totalPrice;
						
						if(row.value.affiliateAmount) {
						    total = total - row.value.affiliateAmount;
						    result += `
						        Tạm tính: <b>${row.value.totalPrice.toLocaleString()} VND</b>
						        <br />
						        Hoa hồng: <b>${row.value.affiliateAmount.toLocaleString()} VND</b>
						        <br />
						    `;
						}
						
						result += `
						    Tổng tiền: <b>${total.toLocaleString()} VND</b>
						`;
						
						return result;
					}
				},

				{
					field: 'payment',
					title: "Phương thức thanh toán",
					width: 100,
					template: function(row) {
						var content = KTUtil.isset(row, 'content') && row.content != null ? row.content : [];
						var payment = content["Phương thức thanh toán"];

						var result = ``;

						switch (payment) {
							case "cod":
								result = `<span class="kt-badge kt-badge--warning kt-font-bold kt-badge--inline kt-badge--pill">Ship COD</span>`;
								break;
							case "bank":
								result = `<span class="kt-badge kt-badge--info kt-font-bold kt-badge--inline kt-badge--pill">Chuyển khoản</span>`;
								break;
							default:
								break;
						}
	
						return result;
					},
				},
	
				{
					field: 'status',
					title: nhMain.getLabel('trang_thai'),
					sortable: false,
					width: 90,
					template: function(row) {
						var status = '';
						var statusOptions = {
							0: {'title': nhMain.getLabel('chua_doc'), 'class': 'kt-badge--dark kt-font-bold'},
							2: {'title': nhMain.getLabel('chua_doc'), 'class': 'kt-badge--dark kt-font-bold'},
							1: {'title': nhMain.getLabel('da_doc'), 'class': 'kt-badge--success kt-font-bold'},
						};
						if(KTUtil.isset(row, 'status') && row.status != null){
							status = '<span class="kt-badge ' + statusOptions[row.status].class + ' kt-badge--inline kt-badge--pill">' + statusOptions[row.status].title + '</span>';
						}
						return status;
					}
				},
				
				// {
				// 	field: 'orderStatus',
				// 	title: "Trạng thái đơn hàng",
				// 	sortable: false,
				// 	width: 90,
				// 	template: function(row) {
				// 		var status = '';
				// 		var statusOptions = {
				// 			initial: {'title': "Khởi tạo", 'class': 'kt-badge--dark kt-font-bold'},
				// 			success: {'title': "Đã duyệt", 'class': 'kt-badge--success kt-font-bold'},
				// 			cancel: {'title': "Đã hủy", 'class': 'kt-badge--danger kt-font-bold'},
				// 		};
				// 		if(row.value.orderStatus){
				// 			status = '<span class="kt-badge ' + statusOptions[row.value.orderStatus].class + ' kt-badge--inline kt-badge--pill">' + statusOptions[row.value.orderStatus].title + '</span>';
				// 		}
				// 		return status;
				// 	}
				// },

				{
					field: 'note',
					title: "Ghi chú",
					width: 150,
					template: function(row) {
						var content = KTUtil.isset(row, 'content') && row.content != null ? row.content : [];
						var note = content["Ghi chú"];
						var result = `<div>${note}</div>`;
						return result;
					},
				},
	
				{
					field: 'id',
					title: '',
					width: 100,
					sortable: false,
					template: function(row){
						var result = `
							<a href="${adminPath}/contact/detail/${row.id}" class="btn btn-sm btn-info">
								Xem chi tiết
							</a>
						`;
						return result;
					}
				},
			]
		};
	} else {
		var options = {
			data: {
				type: 'remote',
				source: {
					read: {
						url: adminPath + '/contact/list/json',
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
	
			data_filter: {
				lang: nhMain.lang,
				keyword: $('#nh-keyword').val(),
				status: $('#nh-status').val(),
				form_id: contactId || $('#form_id').val(),
				create_from: $('#create_from').val(),
				create_from: $('#create_from').val()
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
					field: 'form_name',
					title: nhMain.getLabel('ten_form'),
					sortable: false,
					width: 100,
					template: function(row){
						var formContent = KTUtil.isset(row, 'form') && row.form != null ? row.form : {};
						var name = KTUtil.isset(formContent, 'name') && formContent.name != null ? formContent.name : '';
						return name;
					}
				},
				{
					field: 'content',
					title: nhMain.getLabel('noi_dung'),
					sortable: false,
					template: function(row){
						var content = KTUtil.isset(row, 'content') && row.content != null ? row.content : [];
						var result = '';
						var i = 0;
						$.each(content, function(code, value){
							result += '<p class="mb-5">' + code + ': '+ value +'</p>'
							i++;
							if(i == 3) return false;
						});
	
						return result;
					}
				},
	
				{
					field: 'status',
					title: nhMain.getLabel('trang_thai'),
					sortable: false,
					width: 120,
					template: function(row) {
						var status = '';
						var statusOptions = {
							0: {'title': nhMain.getLabel('chua_doc'), 'class': 'kt-badge--dark kt-font-bold'},
							2: {'title': nhMain.getLabel('chua_doc'), 'class': 'kt-badge--dark kt-font-bold'},
							1: {'title': nhMain.getLabel('da_doc'), 'class': 'kt-badge--success kt-font-bold'},
						};
						if(KTUtil.isset(row, 'status') && row.status != null){
							status = '<span class="kt-badge ' + statusOptions[row.status].class + ' kt-badge--inline kt-badge--pill">' + statusOptions[row.status].title + '</span>';
						}
						return status;
					}
				},
	
				{
					field: 'created',
					title: nhMain.getLabel('ngay_nhan'),
					width: 130,
					template: function(row) {
						if(KTUtil.isset(row, 'created') && row.created != null){
							return row.created;
						}
					},
				},
	
				{
					field: 'id',
					title: '',
					width: 120,
					sortable: false,
					template: function(row){
						var result = '<a href="'+ adminPath +'/contact/detail/'+ row.id +'">\
							<i class="fa fa-eye"></i>\
							'+ nhMain.getLabel('xem_chi_tiet') +'\
						</a>';
						return result;
					}
				},
			]
		};
	}

	return {
		listData: function() {
			$('.kt_datepicker').datepicker({
	            format: 'dd/mm/yyyy',
	            todayHighlight: true,
	            autoclose: true,
  			});
  			
			var datatable = $('.kt-datatable').KTDatatable(options);
			$('#nh_status').on('change', function() {
		      	datatable.search($(this).val(), 'status');
		    });

		    $('#create_from').on('change', function() {
		      	datatable.search($(this).val(), 'create_from');
		    });

		    $('#create_to').on('change', function() {
		      	datatable.search($(this).val(), 'create_to');
		    });	

		    $('#form_id').on('change', function() {
		      	datatable.search($(this).val(), 'form_id');
		    });	
		    
		    nhList.eventDefault(datatable, {
		    	url: {
			    	delete: adminPath + '/contact/form/delete',
			    }
		    });

			$('.kt-selectpicker').selectpicker();

            $(document).on('click', '[nh-export]', function(e) {
				e.preventDefault();
				var nhExport = typeof($(this).attr('nh-export')) != _UNDEFINED ? $(this).attr('nh-export') : '';
				KTApp.blockPage(blockOptions);

				nhMain.callAjax({
					url: adminPath + '/contact/list/json',
					data: {
						'data_filter': {
							lang: nhMain.lang,
							keyword: $('#nh-keyword').val(),
							status: $('#nh_status').val(),
							form_id: $('#form_id').val(),
							create_from: $('#create_from').val(),
							create_from: $('#create_from').val()
						},
						'export': nhExport
					}
				}).done(function(response) {
					KTApp.unblockPage();
					var code = typeof(response.code) != _UNDEFINED ? response.code : _ERROR;
					var message = typeof(response.message) != _UNDEFINED ? response.message : '';
					var name = typeof(response.meta.name) != _UNDEFINED ? response.meta.name : '';

					var $tmp = $("<a>");
		            $tmp.attr("href",response.data);
		            $("body").append($tmp);
		            $tmp.attr("download", name + '.xlsx');
		            $tmp[0].click();
		            $tmp.remove();

					if (code == _SUCCESS) {
		            	toastr.info(message);
		            } else {
		            	toastr.error(message);
		            }
				});
		
				return false;
			});
		}
	};
}();

jQuery(document).ready(function() {
	nhListContact.listData();
});

