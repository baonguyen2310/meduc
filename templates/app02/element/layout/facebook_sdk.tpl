{if !empty($social.facebook_app_id)}
	<script>
	    window.fbAsyncInit = function() {
	        FB.init({
	            appId : '{$social.facebook_app_id}',
	            autoLogAppEvents : true,
	            xfbml : false,
	            version : 'v10.0'
	        });
	    };
	</script>
	<script async defer crossorigin="anonymous" src="https://connect.facebook.net/en_US/sdk.js"></script>
{/if}