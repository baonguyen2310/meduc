{if !empty($social.google_client_id)}
	<script src="https://apis.google.com/js/platform.js?onload=initGoogle" async defer></script>
	<script>
        function initGoogle(){
            gapi.load('auth2', function () {
                auth2 = gapi.auth2.init({
                    client_id: '{$social.google_client_id}'
                });
            });
        }
	</script>
{/if}