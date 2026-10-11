"use strict";

var htmlListLang = '';
if(!$.isEmptyObject(listLanguage)){
	htmlListLang += '<div class="list-flags head-flags text-center" data-toggle="kt-tooltip" title="'+ nhMain.getLabel('danh_sach_theo_ngon_ngu') +'">';
	$.each(listLanguage, function(code, name) {
		var flagDefault = '';
		if(nhMain.lang == code){
			flagDefault = 'flag-default';
		}
	  	htmlListLang += '<a href="?lang='+ code +'"><img src="'+ _FLAGS + code + '.svg" alt="'+ name +'" class="flag ' + flagDefault + '"></a>'
	});
	htmlListLang += '</div>';
}

const addCate = () => {
	const urlParams = new URLSearchParams(window.location.search);
	const cate = urlParams.get("cate");

	const btnAdd = document.querySelector("#kt_subheader .kt-subheader__toolbar .btn");
	btnAdd.href = btnAdd.href + `?cate=${cate}`;

	const titlePage = document.querySelector("#kt_subheader .kt-subheader__main .kt-subheader__title span");
	const id_categories = document.querySelector("#id_categories");
	const text = id_categories.querySelector(`option[value="${cate}"]`).innerText;
	titlePage.innerText = text;
}

var quickUpload = {
	idModal: '#quick-upload',
	inputUpload: 'input#album',
	init: function(){
		var self = this;

		nhMain.selectMedia.album.init();

		$(document).on('click', '[upload-id]', function() {
			$(self.idModal).modal('show');

			var id = $(this).attr('upload-id');

			if(!nhMain.utilities.notEmpty(id)) return false;

			self.loadContentModalUpload(id);

		});

		$(document).on('click', '.btn-quick-upload', function() {
			var id = $(self.idModal).find('input[name="album"]').attr('upload-id');
			var listImages = $(self.idModal).find('input[name="album"]').val();
			
			KTApp.blockPage(blockOptions);
			if(id != _UNDEFINED && id.length > 0){
				nhMain.callAjax({
					url: adminPath + '/product/quick-upload',
					data: {
						id: id,
						images: listImages
					}
				}).done(function(response) {
					KTApp.unblockPage();					
					
					$(self.idModal).modal('hide');
					self.loadTable(id, images);

					var code = typeof(response.code) != _UNDEFINED ? response.code : _ERROR;
		        	var message = typeof(response.message) != _UNDEFINED ? response.message : '';
		        	var data = typeof(response.data) != _UNDEFINED ? response.data : {};
		        	if (code == _SUCCESS) {
		        		var images = typeof(data.images) != _UNDEFINED ? data.images : {};

						self.loadTable(id, images);
						$(self.idModal).modal('hide');
		        	}else{
		        		toastr.error(message);
		        	}
				});
			}
			return false;
		});

		$(self.idModal).on('hidden.bs.modal', function () {
  		  	self.clearModal();
  		});
	},
	loadTable: function(id = null, images = null){
		var self = this;

		var templateImage =  nhList.template.changeImage(id, images);
		$('.kt-datatable').find('[upload-id="' + id + '"]').closest('.symbol-group.symbol-hover').html(templateImage);
	},

	loadContentModalUpload: function(id = null) {
 		var self = this;

 		var modalBody = '.modal-body';
 		var listAlbum = '.list-image-album';
 		var wrapAlbum = '.wrap-album';

		if(id != _UNDEFINED && id.length > 0){
			nhMain.callAjax({
				url: adminPath + '/product/upload-modal/' + id,
				dataType: 'html'
			}).done(function(response) {
				$(self.idModal).find(modalBody).html(response);  
				$(document).ready(function() { 
					$(listAlbum).sortable({
						stop: function( event, ui ) {
							var list_images = [];
					    	$(listAlbum).find('.item-image-album').each(function(index) {
					    		var imageUrl = $(this).data('image');
								list_images.push(imageUrl.replace(cdnUrl, ''));
							});

							var json_value = !$.isEmptyObject(list_images) ? JSON.stringify(list_images) : '';
					      	$(wrapAlbum).find('input').val(json_value);
						}
					});
					$(listAlbum).disableSelection();
				});
			});
		}
	},

	clearModal: function() {
		var self = this;

		$(self.idModal).find('input').val('');
		$(self.idModal).find('.item-image-album').remove();
	}
}

var nhListProduct = function() {
	const urlParams = new URLSearchParams(window.location.search);
	const cate = urlParams.get("cate");

	var options = {
		data: {
			type: 'remote',
			source: {
				read: {
					url: adminPath + '/product/list/json',
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
			id_categories: cate.length > 0 ? [cate] : [],
			price_from: $('#price_from').val(),
			price_to: $('#price_to').val(),
			creator: $('#creator_id').val(),
			product_mark: $('#product_mark').val(),
			display_product: $('#display_product').val(),
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
				field: 'id',
				title: '',
				class: 'w-kt-table w-md-3 w-xs-10',
				type: 'number',
				selector: {class: 'select-record kt-checkbox bg-white'},
				textAlign: 'center',
				autoHide: false,
				sortable: false,
			},
			{
				field: 'name',
				class: 'w-kt-table w-md-25 w-xs-90',
				title: "Tên sản phẩm",
				autoHide: false,
				template: function(row) {
					var name = typeof(row.name) != _UNDEFINED && row.name != null ? row.name : '';
					var url = typeof(row.url) != _UNDEFINED && row.url != null ? row.url : '';
					var urlEdit = adminPath + '/product/update/' + row.id + `?cate=${cate}`;
					var urlDetail = adminPath + '/product/detail/' + row.id;

					var preView = ''
					if(url.length > 0){
						preView = '<span data-toggle="kt-tooltip" title="'+ "Xem sản phẩm" +'" class="view-template kt-margin-l-5"><a target="_blank" href="/'+ url +'"><i class="fa fa-eye"></i></a></span>';
					}
					return '\
						<div class="kt-user-card-v2 kt-user-card-v2--uncircle">\
							<div class="kt-user-card-v2__details">\
								<a href="/'+ url +'" target="_blank" class="d-inline kt-user-card-v2__name">'+ name +'</a>' + preView + '\
								<span class="d-block kt-user-card-v2__desc action-entire">\
									<a href="' + urlEdit + '" class="text-info action-item">'+ nhMain.getLabel('sua') +'</a>\
									<a href="javascript:;" class="action-item text-danger nh-delete" data-id="'+ row.id +'">'+ nhMain.getLabel('xoa') +'</a>\
									<a href="javascript:;" class="action-item text-success nh-change-status" data-id="'+ row.id +'" data-status="1">'+ nhMain.getLabel('hoat_dong') +'</a>\
									<a href="javascript:;" class="action-item nh-change-status" data-id="'+ row.id +'" data-status="0">'+ nhMain.getLabel('ngung_hoat_dong') +'</a>\
							</div>\
						</div>';
				}
			},
			{
				field: 'lang',
				title: htmlListLang,
				class: useMultipleLanguage ? 'w-kt-table w-md-10' : 'd-none',
				sortable: false,
				textAlign: 'center',
				responsive: {
				  	visible: 'md',
				  	hidden: 'xs'
				},
				template: function(row) {
					var mutiple_language = nhMain.utilities.notEmpty(row.mutiple_language) ? row.mutiple_language : [];
					var templateLanguage = '';
					var urlTranslate = adminPath + '/product/update/' + row.id;
					var templateLanguage = '<div class="list-flags">';
					$.each(listLanguage, function(code, name) {
						var flag_class = '';
						if(typeof(mutiple_language[code]) != _UNDEFINED && mutiple_language[code]){
							flag_class = 'text-primary';
						}
					  	templateLanguage += '<a href="'+ urlTranslate + '?lang=' + code +'" class="fa fa-pencil-alt flag ' + flag_class + '" data-toggle="kt-tooltip" title="'+ nhMain.getLabel('dich_sang') + ' ' + name +'">'
					});
					templateLanguage += '</div>';
					return templateLanguage;
				},
			},
			{
				field: 'item_product',
				class: 'w-kt-table w-md-50',
				title: '\
					<div class="row p-0 label-item-product">\
						<div class="col-12 col-md-2">\
							'+ nhMain.getLabel('thuoc_tinh') +'\
						</div>\
						<div class="col-12 col-md-3">\
							<div class="d-inline ml-10" data-toggle="kt-tooltip" title="'+ nhMain.getLabel('danh_sach_anh') +'">\
								<i class="fa fa-image fa-lg "></i>\
							</div>\
						</div>\
						<div class="col-12 col-md-4">\
							'+ nhMain.getLabel('gia_gia_dac_biet') +'\
						</div>\
						<div class="col-12 col-md-2">\
							'+ nhMain.getLabel('so_luong') +'\
						</div>\
						<div class="col-12 col-md-1">\
							<div class="d-inline" data-toggle="kt-tooltip" title="'+ nhMain.getLabel('trang_thai_phien_ban') +'">\
								'+ nhMain.getLabel('TT') +'\
							</div>\
						</div>\
					</div>',
				responsive: {
				  	visible: 'md',
				  	hidden: 'xs'
				},
				sortable: false,
					template: function (row) {
					var html = '';
					if(nhMain.utilities.notEmpty(row.items)){
						var hide = row.items.length > 5 ? true : false;
						var rowHtml = hide ? '<div class="wrap-items d-none">' : '<div class="wrap-items">';						
						$(row.items).each(function(i, item) {
							var product_item_id = nhMain.utilities.notEmpty(item.id) ? item.id : '';
							var code = nhMain.utilities.notEmpty(item.code) ? item.code : '';

							var htmlImages = nhList.template.changeImage(product_item_id, JSON.stringify(item.images));

							var price = nhMain.utilities.notEmpty(item.price) ? nhMain.utilities.parseNumberToTextMoney(item.price) : '';
							var htmlPrice = '\
							<span data-toggle="kt-tooltip" title="' + nhMain.getLabel('gia_san_pham') + '">' 
							+ nhList.template.changeQuick(product_item_id, 'price', price, nhMain.getLabel('gia')) 
							+ '</span>';

							var statusSpecial = {
								true: 'data-toggle="kt-tooltip" title="'+ nhMain.getLabel('gia_dac_biet_da_duoc_ap_dung') +'" class="kt-font-info"',
								false: 'data-toggle="kt-tooltip" title="'+ nhMain.getLabel('gia_dac_biet_khong_duoc_ap_dung') +'" class="kt-font-danger"'
							}

							var price_special = typeof(item.price_special) != _UNDEFINED && item.price_special > 0 ? nhMain.utilities.parseNumberToTextMoney(item.price_special) : '...';

							var htmlApplySpecial = '';
							if(typeof(item.price_special) != _UNDEFINED){
								htmlApplySpecial = statusSpecial[item.apply_special];
							}

							if(item.price_special == 0){
								htmlApplySpecial = '';
							}

							var htmlPriceSpecial = ' / <span ' + htmlApplySpecial + '>' 
							+ nhList.template.changeQuick(product_item_id, 'price_special', price_special, nhMain.getLabel('gia_dac_biet')) 
							+ '</span>';

							var quantity_available = typeof(item.quantity_available) != _UNDEFINED && item.quantity_available > 0 ? item.quantity_available : '...';
							var htmlQuantity = '\
							<span data-toggle="kt-tooltip" title="' + nhMain.getLabel('thay_doi_so_luong') +'">' 
							+ nhList.template.changeQuick(product_item_id, 'quantity_available', quantity_available, nhMain.getLabel('so_luong')) 
							+ '</span>';

							var htmlAttribute = nhMain.utilities.notEmpty(item.attribute_name) ? item.attribute_name : '';

							var statusOptions = {
								0: {'class': 'kt-badge kt-badge--danger kt-badge--dot', 'tooltipHtml': 'data-toggle="kt-tooltip" title="'+ nhMain.getLabel('ngung_hoat_dong') +'"'},
								1: {'class': 'kt-badge kt-badge--success kt-badge--dot', 'tooltipHtml': 'data-toggle="kt-tooltip" title="'+ nhMain.getLabel('hoat_dong') +'"'}
							};

							var item_status = nhMain.utilities.notEmpty(item.status) ? item.status : '';
							var htmlItemStatus = '<span ' + statusOptions[item_status].tooltipHtml + ' class="' + statusOptions[item_status].class + '"></span>';
							
						  	rowHtml += '\
							  	<div class="row p-0 list-item-product">\
							  		<div class="col-12 col-md-2">\
							  			<div class="product-attribute">'+ htmlAttribute +'</div>\
							  		</div>\
							  		<div class="col-12 col-md-3">\
							  			'+ htmlImages +'\
							  		</div>\
							  		<div class="col-12 col-md-4">\
							  			'+ htmlPrice + htmlPriceSpecial +'\
							  		</div>\
							  		<div class="col-12 col-md-2">\
							  			'+ htmlQuantity +'\
							  		</div>\
							  		<div class="col-12 col-md-1">\
							  			'+ htmlItemStatus +'\
							  		</div>\
							  	</div>';
						});
						rowHtml += '</div>';

						if(hide){
							rowHtml += '<span class="show-list-item text-primary cursor-p">' + row.items.length + ' ' + nhMain.getLabel('phien_ban') + '</span>'
							rowHtml += '<span class="hide-list-item text-primary cursor-p mt-20 d-none">' + nhMain.getLabel('an_tat_ca_phien_ban') + '</span>'
						}
						html += rowHtml;
					}

					return html;
				}
			},
			{
				field: 'position',
				class: 'w-kt-table w-md-5',
				title: nhMain.getLabel('vi_tri'),
				sortable: false,
				textAlign: 'center',
				responsive: {
				  	visible: 'md',
				  	hidden: 'xs'
				},
				template: function (row) {
					var position = '';
					if(KTUtil.isset(row, 'position') && row.position != null){
						position = nhMain.utilities.parseNumberToTextMoney(row.position);
					}
					return nhList.template.changeQuick(row.id, 'position', position, nhMain.getLabel('vi_tri'));
				}
			},
			{
				field: 'status',
				class: 'w-kt-table w-md-10',
				title: nhMain.getLabel('trang_thai'),
				responsive: {
				  	visible: 'md',
				  	hidden: 'xs'
				},
				template: function(row) {
					var status = '';
					var draftProduct = '';
					if(KTUtil.isset(row, 'status') && row.status != null && row.draft != 1){
						status = nhList.template.statusProduct(row.status);
					}
					
					if((KTUtil.isset(row, 'draft') && row.draft == 1)){
						draftProduct = nhList.template.draftProduct(row.draft);
					}
					return status + draftProduct;
				},
			}
		]
	}

	return {
		listData: function() {
			lightbox.option({
              'resizeDuration': 200,
              'wrapAround': true,
              'albumLabel': ' %1 '+ nhMain.getLabel('tren') +' %2'
            });

			$('.kt_datepicker').datepicker({
	            format: 'dd/mm/yyyy',
	            todayHighlight: true,
	            autoclose: true,
  			});

			$('.number-input').each(function() {
				nhMain.input.inputMask.init($(this), 'number');
			});

			var datatable = $('.kt-datatable').KTDatatable(options);
			
		    $('#nh_status').on('change', function() {
		      	datatable.search($(this).val(), 'status');
		    });		   	

		    $('#id_categories').on('change', function() {
		      	datatable.search($(this).val().length > 0 ? [$(this).val()] : [], 'id_categories');
		    });	

		    $('#price_from').on('change', function() {
		      	datatable.search($(this).val(), 'price_from');
		    });	

		    $('#price_to').on('change', function() {
		      	datatable.search($(this).val(), 'price_to');
		    });	   

		    $('#id_brands').on('change', function() {
		      	datatable.search([$(this).val()], 'id_brands');
		    });

		    $('#created_by').on('change', function() {
		      	datatable.search($(this).val(), 'created_by');
		    });	

		    $('#product_mark').on('change', function() {
		      	datatable.search($(this).val(), 'product_mark');
		    });	

		    $('#display_product').on('change', function() {
		      	datatable.search($(this).val(), 'display_product');
		    });

		    $('#stocking').on('change', function() {
		      	datatable.search($(this).val(), 'stocking');
		    });

		    $('#create_from').on('change', function() {
		      	datatable.search($(this).val(), 'create_from');
		    });

		    $('#create_to').on('change', function() {
		      	datatable.search($(this).val(), 'create_to');
		    });	

		    $('#has_image').on('change', function() {
		      	datatable.search($(this).val(), 'has_image');
		    });	

		    //event delete and change status on list
		    nhList.eventDefault(datatable, {
		    	url: {
			    	delete: adminPath + '/product/delete',
			    	status: adminPath + '/product/change-status',
			    	quickChange: adminPath + '/product/quick-change',
			    }
		    });

		    $(document).on('click', '.kt-datatable .show-list-item', function() {
		    	var td = $(this).closest('td');
		    	$(this).addClass('d-none');

				td.find('.wrap-items').removeClass('d-none');
				td.find('.hide-list-item').removeClass('d-none').addClass('d-block');
			});

			$(document).on('click', '.kt-datatable .hide-list-item', function() {
		    	var td = $(this).closest('td');
		    	$(this).addClass('d-none').removeClass('d-block');

				td.find('.wrap-items').addClass('d-none');
				td.find('.show-list-item').removeClass('d-none')
			});

			$(document).on('click', '[nh-dowload-file-import]', function(e) {
				e.preventDefault();
				KTApp.blockPage(blockOptions);

				nhMain.callAjax({
					url: adminPath + '/product/download-file-import',
				}).done(function(response) {
					KTApp.unblockPage();
					var code = typeof(response.code) != _UNDEFINED ? response.code : _ERROR;
					var message = typeof(response.message) != _UNDEFINED ? response.message : '';
					var name = typeof(response.meta.name) != _UNDEFINED ? response.meta.name : '';

					var $tmp = $("<a>");
		            $tmp.attr("href",response.data);
		            $("body").append($tmp);
		            $tmp.attr("download", name + '.xls');
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

			$(document).on('click', '[nh-export]', function(e) {
                e.preventDefault();
                KTApp.blockPage(blockOptions);
                var nhExport = typeof($(this).attr('nh-export')) != _UNDEFINED ? $(this).attr('nh-export') : '';

                var data_filter = {
					lang: nhMain.lang,
					keyword: $('#nh-keyword').val(),
					status: $('[name=status]').val(),
					id_categories: $('#id_categories').val().length > 0 ? [$('#id_categories').val()] : [],
					price_from: $('#price_from').val(),
					price_to: $('#price_to').val(),
					creator: $('#creator_id').val(),
					product_mark: $('#product_mark').val(),
					display_product: $('#display_product').val(),
				}

                nhMain.callAjax({
                    url: adminPath + '/product/list/json',
					data: {
						'data_filter': data_filter,
						'get_categories': true,
						'get_attributes': true,
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

            $(document).on('click', '#btn-import-excel', function(e) {
            	e.preventDefault();
                KTApp.blockPage(blockOptions);

                var file_input = $('#excel_file');
                var file_data = file_input[0].files;
                if(file_input.length == 0){
					nhMain.showLog(nhMain.getLabel('khong_tim_thay_du_lieu_file'));
				}

                var formData = new FormData();
                $.each(file_data, function(index, file) {
					formData.append("excel_file", file);				
				});

             	nhMain.callAjax({
		    		async: true,
					url: adminPath + '/product/import-excel',
					data: formData,
					contentType: false,
					processData: false,
				}).done(function(response) {
					KTApp.unblockPage();					

					var code = typeof(response.code) != _UNDEFINED ? response.code : _ERROR;
		        	var message = typeof(response.message) != _UNDEFINED ? response.message : '';
		        	var data = typeof(response.data) != _UNDEFINED ? response.data : {};
		        	
		        	if (code == _SUCCESS) {
		        		toastr.success(message);
		        		$('#import-excel-modal').modal('hide');
		        	}else{
		        		toastr.error(message);
		        	}
				});

				return false;
			});				

		    $('.kt-selectpicker').selectpicker();
			$('body').tooltip({ selector: '[data-toggle=kt-tooltip]' });

		    quickUpload.init();
		}
	};
}();

jQuery(document).ready(function() {
	addCate();

	nhListProduct.listData();
});

