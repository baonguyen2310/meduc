<?php
declare(strict_types=1);
if(PHP_SAPI!=='cli'||!in_array('--send',$argv,true))exit("Use --send\n");
$root=dirname(__DIR__);define('SOURCE_DOMAIN',$root);require $root.'/config_database.php';require $root.'/coredaca/vendor/autoload.php';$app=new App\Application($root.'/coredaca/config');$app->bootstrap();
$controller=new App\Controller\CheckoutController(new Cake\Http\ServerRequest());$email=$controller->loadComponent('Email');
echo json_encode(['sent'=>App\Service\CommerceNotifications::retry(function($p)use($email){return $email->sendEmail($p);})])."\n";
