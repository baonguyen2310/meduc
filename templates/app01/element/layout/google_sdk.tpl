{if !empty($social.google_client_id)}
	{*<script src="https://apis.google.com/js/platform.js?onload=initGoogle" async defer></script>
	<script>
        function initGoogle(){
            gapi.load('auth2', function () {
                auth2 = gapi.auth2.init({
                    client_id: '{$social.google_client_id}'
                });
            });
        }
	</script>*}
	
	{assign member_info value = $this->Member->getMemberInfo()}
	
	{if empty($member_info.id)}
	    <script>
    	    function decodeJwtResponse(token) {
                const base64Url = token.split('.')[1];
                const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
                const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
                    return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
                }).join(''));
                
                // Parse the JSON string into an object
                return JSON.parse(jsonPayload);
            }
    	
    	    function handleCredentialResponse(res) {
    	        const responsePayload = decodeJwtResponse(res.credential);
    	        
    	        console.log(res);
    	        console.log(responsePayload);
    
                console.log("ID: " + responsePayload.sub);
                console.log('Full Name: ' + responsePayload.name);
                console.log('Given Name: ' + responsePayload.given_name);
                console.log('Family Name: ' + responsePayload.family_name);
                console.log("Image URL: " + responsePayload.picture);
                console.log("Email: " + responsePayload.email);
                var data = {
                    social_id: responsePayload.sub,
                    type: 'google',
                    full_name: responsePayload.name,
                    email: responsePayload.email,
                    picture: responsePayload.picture,
                    redirect: "/member/dashboard"
                }
    	        
    	        nhMain.callAjax({
        			url: '/member/social-login',
        			data: data
        		}).done(function(response) {
        		   	var code = typeof(response.code) != _UNDEFINED ? response.code : _ERROR;
                	var message = typeof(response.message) != _UNDEFINED ? response.message : '';
                	var data = typeof(response.data) != _UNDEFINED ? response.data : {};
        
                	nhMain.showLoading.remove();
                	
                    if (code == _SUCCESS) {
                    	nhMain.showAlert(_SUCCESS, message);
                    	var action = nhMain.utilities.notEmpty(response.action) ? response.action : null;
        
                    	if(action == 'add'){
                    		window.location.href = '/member/dashboard';
                    	}
        
                    	if(nhMain.utilities.notEmpty(data.redirect)){
                    		window.location.href = data.redirect;
                    	} else {
                    		window.location.href = '/member/dashboard';
                    	}
                    } else {
                    	nhMain.showAlert(_ERROR, message);
                    }
        
        
        		});
    	    }
    	</script>
    	
    	<script src="https://accounts.google.com/gsi/client" async defer></script>
    	<div id="g_id_onload"
             data-client_id="{$social.google_client_id}"
             data-callback="handleCredentialResponse">
        </div>
        <div class="pp-login-google">
            <div class="g_id_signin" data-type="standard"></div>
            <button class="btn-close"></button>
        </div>
	{/if}
{/if}