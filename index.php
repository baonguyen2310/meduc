<?php
header('User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.1 Safari/537.36');
//------------------------------------ cấu hình riêng cho mỗi website
require __DIR__ . '/config.php';
require __DIR__ . '/config_database.php';

//------------------------------------ cấu hình đường dẫn folder core local
// $core_path = dirname(__DIR__) . DIRECTORY_SEPARATOR . 'web4s' ;

//------------------------------------ cấu hình đường dẫn folder core trên môi trường live
$core_path = dirname(__FILE__) . DIRECTORY_SEPARATOR . 'coredaca' ;
// $core_path = dirname(dirname(__DIR__)) . DIRECTORY_SEPARATOR . 'coredaca';

require $core_path . '/config/requirements.php';

if (!defined('SOURCE_DOMAIN')) {
    define('SOURCE_DOMAIN', __DIR__);
}

// For built-in server
if (PHP_SAPI === 'cli-server') {
    $_SERVER['PHP_SELF'] = '/' . basename(__FILE__);

    $url = parse_url(urldecode($_SERVER['REQUEST_URI']));
    $file = __DIR__ . $url['path'];
    if (strpos($url['path'], '..') === false && strpos($url['path'], '.') !== false && is_file($file)) {
        return false;
    }
}

require $core_path . '/vendor/autoload.php';

use App\Application;
use Cake\Http\Server;

// Bind your application to the server.
$server = new Server(new Application($core_path . '/config'));

// Run the request/response through the application and emit the response.
$server->emit($server->run());
