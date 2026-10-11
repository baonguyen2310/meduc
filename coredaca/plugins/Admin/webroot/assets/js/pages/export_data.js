"use strict";

var nhExportData = {
	init: function(){
		var self = this;
		self.initializationStep.init();
		// self.migrateStep.init();
		// self.exportStep.init();
	},
	initializationStep: {
		init: function(){
			var self = this;

			self.event();
		},
		event: function () {
			var self = this;
			$(document).on('click', '.btn-export-data:not(.disabled)', function(e) {
				e.preventDefault();

				var type = $(this).attr('type');
				var url = null;
				switch(type){
					case 'initialization':
						url = adminPath + '/setting/export-data/initialization';
					break;

					case 'read_database':
						url = adminPath + '/setting/export-data/read-database';
					break;
				}

				if(url == null) return false;

				KTApp.blockPage(blockOptions);
				nhMain.callAjax({
		            url: url,
		            type: 'POST'
		        }).done(function(response) {
		        	var code = typeof(response.code) != _UNDEFINED ? response.code : _ERROR;
		        	var message = typeof(response.message) != _UNDEFINED ? response.message : '';
		        	if (code == _SUCCESS) {
		        		toastr.success(message);
		        		location.reload();
		            } else {
		            	toastr.error(message);
		            	setTimeout(function(){ location.reload(); }, 2000);
		            }
		            
		            KTApp.unblockPage();
		        });
			});

			$(document).on('click', '[nh-show-attributes]', function(e) {
				e.preventDefault();
				var attribute_type = $(this).attr('type');
				var wrapHtml = $('[nh-list-attributes]');

				if ($(this).hasClass('btn-success')) {
					wrapHtml.find('.listbox-content').html('');
					wrapHtml.addClass('d-none');
					$(this).removeClass('btn-success');

					return false;
				}

				if (typeof(attribute_type) == _UNDEFINED || attribute_type == null || attribute_type == '' || wrapHtml.length == 0) return false;

				$('[nh-show-attributes]').removeClass('btn-success');
				$(this).addClass('btn-success');

				nhMain.callAjax({
		            url: adminPath + '/setting/export-data/load-list-attributes',
		            type: 'POST',
		            data: {
		            	data_filter: {
		            		attribute_type: attribute_type
		            	}
		            },
		            dataType: _HTML,
		        }).done(function(response) {
		        	wrapHtml.find('.listbox-content').html(response);
		        	wrapHtml.removeClass('d-none');
		        });
			});

			$(document).on('click', '[nh-save-config-attributes]', function(e) {
				e.preventDefault();
				var formElement = $('#config-attribute-form');
				if (formElement.length == 0) return false;

				var formData = formElement.serialize();
				nhMain.callAjax({
		            url: formElement.attr('action'),
		            type: 'POST',
		            data: formData
		        }).done(function(response) {
		        	var code = typeof(response.code) != _UNDEFINED ? response.code : _ERROR;
		        	var message = typeof(response.message) != _UNDEFINED ? response.message : '';
		        	if (code == _SUCCESS) {
		        		toastr.success(message);
		            } else {
		            	toastr.error(message);
		            }
		            
		            KTApp.unblockPage();
		        });
			});

			// cấu hình dữ liệu export
			self.eventModalConfigData();

			// cấu hình ID bản ghi
			self.eventModalConfigId();

			// cấu hình chung
			self.eventModalConfigCdn();
		},
		eventModalConfigData: function(){
			var self = this;

			var formConfigDataElement = $('#config-data-form');
			var modalConfigData = $('#config-data-modal');
			if (formConfigDataElement.length == 0 || modalConfigData.length == 0) return false;
			
			$(document).on('click', '#btn-show-config-data:not(.disabled)', function(e) {
				e.preventDefault();
				modalConfigData.modal('show');
			});

			$(document).on('click', '#btn-config-data', function(e) {
				var languages = [];
				if ($('[nh-config-lang]').length != 0) {

					$('[nh-config-lang]:checked').each(function() {
						let lang = $(this).val();
						languages.push(lang);
					})
				}

				var formData = formConfigDataElement.serialize();
				formData = formData + '&languages=' + languages.join('-');
				nhMain.callAjax({
					url: formConfigDataElement.attr('action'),
					data: formData
				}).done(function(response) {
					// hide loading
					KTApp.unprogress(btn_save);
					KTApp.unblockPage();

					//show message and redirect page
				   	var code = typeof(response.code) != _UNDEFINED ? response.code : _ERROR;
		        	var message = typeof(response.message) != _UNDEFINED ? response.message : '';
		        	var data = typeof(response.data) != _UNDEFINED ? response.data : {};
		        	toastr.clear();
		            if (code == _SUCCESS) {
		            	toastr.info(message);
		            	if(typeof(data.id) != _UNDEFINED && isUpdate == 1 && urlRedirect.length > 0){
		            		urlRedirect = urlRedirect + '/' +  data.id
		            	}            	

		            	if(urlRedirect.length > 0){
		            		window.location.href = urlRedirect;
		            	}else{
		            		location.reload();
		            	}
		            } else {
		            	toastr.error(message);
		            }
				});
			});
		},
		eventModalConfigId: function(){
			var self = this;

			var formConfigIdElement = $('#config-id-form');
			var validatorConfigId = formConfigIdElement.validate({
				ignore: ':hidden',
				rules: {
					category_id_start: {
						required: true
					},
					article_id_start: {
						required: true,
					},
					product_id_start: {
						required: true,
					},
					tag_id_start: {
						required: true,
					},
					attribute_id_start: {
						required: true,
					}
				},
				messages: {
					category_id_start: {
	                    required: 'Vui lòng nhập thông tin'
	                },
	                category_id_start: {
	                    required: 'Vui lòng nhập thông tin'
	                },
	                product_id_start: {
	                    required: 'Vui lòng nhập thông tin'
	                },
	                tag_id_start: {
	                    required: 'Vui lòng nhập thông tin'
	                },
	                attribute_id_start: {
	                    required: 'Vui lòng nhập thông tin'
	                }
	            },
	            errorPlacement: function(error, element) {
	                var group = element.closest('.input-group');
	                if (group.length) {
	                    group.after(error.addClass('invalid-feedback'));
	                }else{                	
	                    element.after(error.addClass('invalid-feedback'));
	                }
	            },
				invalidHandler: function(event, validator) {
					validator.errorList[0].element.focus();
				},
			});

			$(document).on('click', '#btn-show-config-id:not(.disabled)', function(e) {
				e.preventDefault();
				var modal = $('#config-id-modal');

				modal.find('input.number-input').each(function() {
					nhMain.input.inputMask.init($(this), 'numeric');
				});

				modal.modal('show');
			});

			$(document).on('click', '#btn-config-id:not(.disabled)', function(e) {
				e.preventDefault();
				if (!validatorConfigId.form()) return false;

				var formData = formConfigIdElement.serialize();
				KTApp.blockPage(blockOptions);
				nhMain.callAjax({
		            url: formConfigIdElement.attr('action'),
		            type: 'POST',
		            data: formData
		        }).done(function(response) {
		        	var code = typeof(response.code) != _UNDEFINED ? response.code : _ERROR;
		        	var message = typeof(response.message) != _UNDEFINED ? response.message : '';
		        	if (code == _SUCCESS) {
		        		toastr.success(message);
		        		location.reload();
		            } else {
		            	toastr.error(message);
		            	setTimeout(function(){ location.reload(); }, 2000);
		            }
		            
		            KTApp.unblockPage();
		        });
			});
		},
		eventModalConfigCdn: function(){
			var self = this;

			var formConfigGeneralElement = $('#config-general-form');
			var validatorConfigGeneral = formConfigGeneralElement.validate({
				ignore: ':hidden',
				rules: {
					url_website: {
						required: true
					}
				},
				messages: {
					url_website: {
	                    required: 'Vui lòng nhập thông tin'
	                }
				},
	            errorPlacement: function(error, element) {
	                var group = element.closest('.input-group');
	                if (group.length) {
	                    group.after(error.addClass('invalid-feedback'));
	                }else{                	
	                    element.after(error.addClass('invalid-feedback'));
	                }
	            },
				invalidHandler: function(event, validator) {
					validator.errorList[0].element.focus();
				},
			});

			$(document).on('click', '#btn-show-config-general:not(.disabled)', function(e) {
				e.preventDefault();
				var modal = $('#config-general-modal');
				modal.modal('show');
			});

			$(document).on('click', '#btn-config-general:not(.disabled)', function(e) {
				e.preventDefault();
				if (!validatorConfigGeneral.form()) return false;

				var formData = formConfigGeneralElement.serialize();
				KTApp.blockPage(blockOptions);
				nhMain.callAjax({
		            url: formConfigGeneralElement.attr('action'),
		            type: 'POST',
		            data: formData
		        }).done(function(response) {
		        	var code = typeof(response.code) != _UNDEFINED ? response.code : _ERROR;
		        	var message = typeof(response.message) != _UNDEFINED ? response.message : '';
		        	if (code == _SUCCESS) {
		        		toastr.success(message);
		        		location.reload();
		            } else {
		            	toastr.error(message);
		            	setTimeout(function(){ location.reload(); }, 2000);
		            }
		            
		            KTApp.unblockPage();
		        });
			});
		}
	},
	migrateStep:{
		init: function(){
			var self = this;
			if(nhMigrate.code == null) return false;
			self.event();
		},
		event: function(){
			var self = this;

			$(document).on('click', '#btn-migrate:not(.disabled)', function(e) {
				e.preventDefault();
				
				var btnMigrate = $(this);

				// show loading
				btnMigrate.find('.icon-spinner').removeClass('d-none');
				btnMigrate.addClass('disabled');

				// start migrate data
				var type = typeof($(this).attr('type')) != _UNDEFINED ? $(this).attr('type') : null;
				self.migrateData(type, function(e) {
					// remove loading
		            btnMigrate.find('.icon-spinner').addClass('d-none');
					btnMigrate.removeClass('disabled');

					location.reload();
				});

	            
			});
		},
		migrateData: function(type = null, callback = null){
			var self = this;
			if(type == null || type.length == 0) return false;

			if (typeof(callback) != 'function') {
 		        callback = function () {};
  		    }

  		    var data = {
            	type: type,
            }

            var extend = {};
  		    $(document).find('input[nh-input-extend]').each(function() {
  		    	var key = $(this).attr('nh-input-extend');
  		    	var value = $(this).val();
  		    	extend[key] = value;		    	
  		    });

  		    data.extend = extend;
			nhMain.callAjax({
	            url: '/migrate-process/migrate-data/' + nhMigrate.code,
	            type: 'POST',
	            data: data
	        }).done(function(response) {
	        	var code = typeof(response.code) != _UNDEFINED ? response.code : _ERROR;
	        	var message = typeof(response.message) != _UNDEFINED ? response.message : '';
	        	var data = typeof(response.data) != _UNDEFINED ? response.data : '';
	        	if (code == _SUCCESS) {
	        		if(typeof(data.migrated) != _UNDEFINED && data.migrated > 0){
	        			$('#label-migrated').html(data.migrated);
	        		}

	        		if(typeof(data.continue) != _UNDEFINED && data.continue){
	        			self.migrateData(type, callback);
	        		}else{	        			
	        			toastr.success(message);
	        			callback(response);
	        		}
	            } else {
	            	toastr.error(message);
	            }
	            
	            KTApp.unblockPage();
	        });

		}
	},
	exportStep: {
		init: function(){
			var self = this;
			if(nhMigrate.code == null) return false;
			self.event();
		},
		event: function(){
			var self = this;

			$(document).on('click', '#btn-export:not(.disabled)', function(e) {
				e.preventDefault();
				
				var btnMigrate = $(this);

				// show loading
				btnMigrate.find('.icon-spinner').removeClass('d-none');
				btnMigrate.addClass('disabled');

				// start migrate data
				var type = typeof($(this).attr('type')) != _UNDEFINED ? $(this).attr('type') : null;
				self.exportData(function(e) {
					// remove loading
		            btnMigrate.find('.icon-spinner').addClass('d-none');
					btnMigrate.removeClass('disabled');

					location.reload();
				});

	            
			});
		},
		exportData: function(callback) {
			var self = this;

			if (typeof(callback) != 'function') {
 		        callback = function () {};
  		    }

			nhMain.callAjax({
	            url: '/migrate-process/export-data/' + nhMigrate.code,
	            type: 'POST'
	        }).done(function(response) {
	        	var code = typeof(response.code) != _UNDEFINED ? response.code : _ERROR;
	        	var message = typeof(response.message) != _UNDEFINED ? response.message : '';
	        	var data = typeof(response.data) != _UNDEFINED ? response.data : '';
	        	if (code == _SUCCESS) {
	        		toastr.success(message);
	        		callback(response);
	            } else {
	            	toastr.error(message);
	            }
	            
	            KTApp.unblockPage();
	        });
		}
	}
}

$(document).ready(function() {
	nhExportData.init();
});