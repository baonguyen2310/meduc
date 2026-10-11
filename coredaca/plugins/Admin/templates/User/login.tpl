<!DOCTYPE html>
<html lang="en">
	<head>
		<base href="">
		<meta charset="utf-8" />
		<title>Daca.vn | {__d('admin', 'dang_nhap')}</title>
		<meta name="description" content="{__d('admin', 'dang_nhap')}">
		<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

		<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Poppins:300,400,500,600,700|Roboto:300,400,500,600,700">

		<link href="{ADMIN_PATH}/assets/css/pages/login/login-2.css" rel="stylesheet" type="text/css" />


		<link href="{ADMIN_PATH}/assets/plugins/global/plugins.bundle.css" rel="stylesheet" type="text/css" />
		<link href="{ADMIN_PATH}/assets/css/style.bundle.css" rel="stylesheet" type="text/css" />


		<link href="{ADMIN_PATH}/assets/css/skins/header/base/light.css" rel="stylesheet" type="text/css" />
		<link href="{ADMIN_PATH}/assets/css/skins/header/menu/light.css" rel="stylesheet" type="text/css" />
		<link href="{ADMIN_PATH}/assets/css/skins/brand/dark.css" rel="stylesheet" type="text/css" />
		<link href="{ADMIN_PATH}/assets/css/skins/aside/dark.css" rel="stylesheet" type="text/css" />


		<link rel="shortcut icon" href="{ADMIN_PATH}/favicon.ico" />
	</head>

	<body class="kt-quick-panel--right kt-demo-panel--right kt-offcanvas-panel--right kt-header--fixed kt-header-mobile--fixed kt-subheader--enabled kt-subheader--fixed kt-subheader--solid kt-aside--enabled kt-aside--fixed kt-page--loading">

		<div class="kt-grid kt-grid--ver kt-grid--root">
			<div class="kt-grid kt-grid--hor kt-grid--root  kt-login kt-login--v2 kt-login--signin" id="kt_login">
				<div class="kt-grid__item kt-grid__item--fluid kt-grid kt-grid--hor" style="background-image: url({ADMIN_PATH}/assets/media/bg/bg-1.jpg); background-size: cover;">
					<div class="kt-grid__item kt-grid__item--fluid kt-login__wrapper">
						<div class="kt-login__container">
							<div class="kt-login__logo">
								<img style="height: 80px" alt="Logo" src="{ADMIN_PATH}/assets/media/logos/logodaca-white.svg">
							</div>

							<div class="kt-login__signin">
								<div class="kt-login__head">
									<h3 class="kt-login__title">
										{__d('admin', 'dang_nhap_quan_tri')}
									</h3>
								</div>

								<form id="form-login" class="kt-form" action="{ADMIN_PATH}/ajax-login" method="post">
									<div class="input-group text-center">
										<input name="username" class="form-control form-control-sm" type="text" autocomplete="off" placeholder="{__d('admin', 'tai_khoan')}">
									</div>

									<div class="input-group text-center">
										<input name="password" class="form-control form-control-sm" type="password" placeholder="{__d('admin', 'mat_khau')}">
									</div>

									<input type="hidden" name="redirect" value="{if !empty($redirect)}{$redirect}{/if}">
									<div class="row kt-login__extra">
										<div class="col">
											<label class="kt-checkbox">
												<input type="checkbox" name="remember">
												{__d('admin', 'ghi_nho_tai_khoan')}
												<span></span>
											</label>
										</div>
									</div>

									<div class="kt-login__actions">
										<span id="btn-login" class="btn btn-brand btn-pill kt-login__btn-primary" disabled>
											{__d('admin', 'dang_nhap')}
										</span>
									</div>
								</form>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>

		<script type="text/javascript">
			var adminPath = '{ADMIN_PATH}';			
			var csrfToken = '{$this->getRequest()->getAttribute("csrfToken")}';
		</script>

		<script src="{ADMIN_PATH}/assets/plugins/global/plugins.bundle.js" type="text/javascript"></script>
		<script src="{ADMIN_PATH}/assets/plugins/global/scripts.bundle.js" type="text/javascript"></script>

		<script src="{ADMIN_PATH}/assets/js/locales/{$lang}.js" type="text/javascript"></script>
		<script src="{ADMIN_PATH}/assets/js/constants.js" type="text/javascript"></script>
		<script src="{ADMIN_PATH}/assets/js/main.js" type="text/javascript"></script>
		<script src="{ADMIN_PATH}/assets/js/pages/login.js" type="text/javascript"></script>

	</body>

</html>