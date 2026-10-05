"use strict";

var nhListPayment = function() {
	var options = {
		data: {
			type: 'remote',
			source: {
				read: {
					url: adminPath + '/payment/list/json',
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
				field: 'code',
				title: nhMain.getLabel('ma_giao_dich'),
				sortable: false,
				width: 220,
				autoHide: false,
				template: function(row){
					var code = typeof(row.code) != _UNDEFINED && row.code != null ? row.code : '';
					var created = typeof(row.created) != _UNDEFINED && row.created != null ? row.created : '';
					var detailUrl = adminPath + '/payment/detail/' + code;

					return '\
					<div class="code-time nh-weight">\
						<div class="mb-5"> <i class="fas fa-qrcode"></i> <a href="' + detailUrl + '">' + code +'</a></div>\
						<div> <i class="far fa-clock"></i> '+ nhMain.utilities.parseIntToDateTimeString(row.created) +'</div>\
					</div>';
				}
			},

			{
				field: 'full_name',
				title: nhMain.getLabel('nguoi_giao_dich'),
				sortable: false,
				template: function(row){
					var full_name = typeof(row.full_name) != _UNDEFINED && row.full_name != null ? row.full_name : '';

					if(typeof(row.object_type) != _UNDEFINED && row.object_type != null && row.object_type == 'customer') {
						var customerURL = adminPath + '/customer/detail/' + row.object_id;
						full_name = '<a target="_blank" href="' + customerURL + '">' + full_name +'</a>';
					}

					return full_name;
				}
			},

			{
				field: 'payment_method',
				title: nhMain.getLabel('phuong_thuc_thanh_toan'),
				sortable: false,
				template: function(row){
					var paymentMethod = '';
					var paymentMethodOptions = {
						'cash': nhMain.getLabel('tien_mat'),
						'bank': nhMain.getLabel('chuyen_khoan'),
						'credit': nhMain.getLabel('quet_the'),
						'cod': nhMain.getLabel('cod')
					};
					if(KTUtil.isset(row, 'payment_method') && row.payment_method != null){
						paymentMethod = '<span>' + paymentMethodOptions[row.payment_method] + '</span>';
					}
					return paymentMethod;
				}
			},

			{
				field: 'amount',
				title: nhMain.getLabel('so_tien'),
				template: function(row) {
					return nhMain.utilities.parseNumberToTextMoney(nhMain.utilities.parseFloat(row.amount));
				},
			},

			{
				field: 'note',
				title: nhMain.getLabel('ghi_chu'),
				sortable: false,
				template: function(row){
					var note = typeof(row.note) != _UNDEFINED && row.note != null ? row.note : '';

					return '\
					<div class="nh-note-customer">' + nhList.template.changeNote(row.id, 'note', note, nhMain.getLabel('ghi_chu')) + '</div>\
					';
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
						0: {'title': nhMain.getLabel('da_huy'), 'class': 'kt-badge--dark kt-font-bold'},
						1: {'title': nhMain.getLabel('thanh_cong'), 'class': 'kt-badge--success kt-font-bold'},
						2: {'title': nhMain.getLabel('cho_xet_duyet'), 'class': 'kt-badge--danger kt-font-bold'}
					};
					if(KTUtil.isset(row, 'status') && row.status != null){
						status = '<span class="kt-badge ' + statusOptions[row.status].class + ' kt-badge--inline kt-badge--pill">' + statusOptions[row.status].title + '</span>';
					}
					return status;
				}
			}
		]
	};

	return {
		listData: function() {
			var datatable = $('.kt-datatable').KTDatatable(options);
			$('#nh_status').on('change', function() {
		      	datatable.search($(this).val(), 'status');
		    });

		    $('#payment_method').on('change', function() {
		      	datatable.search($(this).val(), 'payment_method');
		    });

			$('#price_from').on('change', function() {
		      	datatable.search($(this).val(), 'price_from');
		    });

		    $('#price_to').on('change', function() {
		      	datatable.search($(this).val(), 'price_to');
		    });

		    $('#create_from').on('change', function() {
		      	datatable.search($(this).val(), 'create_from');
		    });

		    $('#create_to').on('change', function() {
		      	datatable.search($(this).val(), 'create_to');
		    });	

		    $('#payment_from').on('change', function() {
		      	datatable.search($(this).val(), 'payment_from');
		    });

		    $('#payment_to').on('change', function() {
		      	datatable.search($(this).val(), 'payment_to');
		    });

		    $('#note').on('change', function() {
		      	datatable.search($(this).val(), 'note');
		    }); 

		    $('.number-input').each(function() {
				nhMain.input.inputMask.init($(this), 'number');
			});

			// event delete and change status on list
		    nhList.eventDefault(datatable, {
		    	url: {
			    	note: adminPath + '/payment/change-note'
			    }
		    });

			$('.kt-selectpicker').selectpicker();
			$('.kt_datepicker').datepicker({
				format: 'dd/mm/yyyy',
	            todayHighlight: true,
	            autoclose: true,
			});

			$(document).on('mouseenter', '.kt-datatable .popover-payment-method', function() {
				$(this).popover({
	    			html: true,
	    			trigger: 'hover',
	    			placement: 'top'
		        });
		        $(this).popover('show');
		    });
		}
	};
}();

jQuery(document).ready(function() {
	nhListPayment.listData();
});

