<?php

$version = "9.14.0";
error_reporting(E_ERROR | E_PARSE);

if (session_id() == '') {
    session_start();
}

$base_folder = dirname(dirname(dirname(__FILE__)));




// ------------------------- CHECK AUTHENTICATION ----------------------------


// LOCAL DEV
require dirname($base_folder) . DIRECTORY_SEPARATOR .'web4s\filemamager_auth.php';

// LIVE
// require '/home/web4s/filemamager_auth.php';


// ------------------------- END CHECK AUTHENTICATION ---------------------------




// ------------------- update dir config by template_code

$config['upload_dir'] = '/templates/' . $template_code . '/assets/media/';
$config['thumbs_upload_dir'] = '/templates/' .  $template_code . '/assets/media_thumbs/';

$config['current_path'] = '..' . $config['upload_dir'];
$config['thumbs_base_path'] = '..' . $config['thumbs_upload_dir'];
$config['fixed_path_from_filemanager'] = [
    $config['thumbs_base_path'], $config['thumbs_base_path'], $config['thumbs_base_path'], $config['thumbs_base_path']
];

if (!is_dir($base_folder . $config['upload_dir'])) {
    die("Folder media in template not exist!");
}




header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: *');
mb_internal_encoding('UTF-8');
mb_http_output('UTF-8');
mb_http_input('UTF-8');
mb_language('uni');
mb_regex_encoding('UTF-8');
ob_start('mb_output_handler');
date_default_timezone_set('Europe/Rome');
setlocale(LC_CTYPE, 'en_US');



return array_merge(
    $config,
    array(
        'ext' => array_merge(
            $config['ext_img'],
            $config['ext_file'],
            $config['ext_misc'],
            $config['ext_video'],
            $config['ext_music']
        ),
        'tui_defaults_config' => array(
            //'common.bi.image'                   => $config['common.bi.image'],
            //'common.bisize.width'               => $config['common.bisize.width'],
            //'common.bisize.height'              => $config['common.bisize.height'], 
            'common.backgroundImage'            => $config['common.backgroundImage'],
            'common.backgroundColor'            => $config['common.backgroundColor'], 
            'common.border'                     => $config['common.border'],
            'header.backgroundImage'            => $config['header.backgroundImage'],
            'header.backgroundColor'            => $config['header.backgroundColor'],
            'header.border'                     => $config['header.border'],
            'menu.normalIcon.path'              => $config['menu.normalIcon.path'],
            'menu.normalIcon.name'              => $config['menu.normalIcon.name'],
            'menu.activeIcon.path'              => $config['menu.activeIcon.path'],
            'menu.activeIcon.name'              => $config['menu.activeIcon.name'],
            'menu.disabledIcon.path'            => $config['menu.disabledIcon.path'],
            'menu.disabledIcon.name'            => $config['menu.disabledIcon.name'],
            'menu.hoverIcon.path'               => $config['menu.hoverIcon.path'],
            'menu.hoverIcon.name'               => $config['menu.hoverIcon.name'],
            'menu.iconSize.width'               => $config['menu.iconSize.width'],
            'menu.iconSize.height'              => $config['menu.iconSize.height'],
            'submenu.backgroundColor'           => $config['submenu.backgroundColor'],
            'submenu.partition.color'           => $config['submenu.partition.color'],
            'submenu.normalIcon.path'           => $config['submenu.normalIcon.path'],
            'submenu.normalIcon.name'           => $config['submenu.normalIcon.name'],
            'submenu.activeIcon.path'           => $config['submenu.activeIcon.path'],
            'submenu.activeIcon.name'           => $config['submenu.activeIcon.name'],
            'submenu.iconSize.width'            => $config['submenu.iconSize.width'],
            'submenu.iconSize.height'           => $config['submenu.iconSize.height'],
            'submenu.normalLabel.color'         => $config['submenu.normalLabel.color'],
            'submenu.normalLabel.fontWeight'    => $config['submenu.normalLabel.fontWeight'],
            'submenu.activeLabel.color'         => $config['submenu.activeLabel.color'],
            //'submenu.activeLabel.fontWeight'    => $config['submenu.activeLabel.fontWeightcommon.bi.image'],
            'checkbox.border'                   => $config['checkbox.border'],
            'checkbox.backgroundColor'          => $config['checkbox.backgroundColor'],
            'range.pointer.color'               => $config['range.pointer.color'],
            'range.bar.color'                   => $config['range.bar.color'],
            'range.subbar.color'                => $config['range.subbar.color'],
            'range.disabledPointer.color'       => $config['range.disabledPointer.color'],
            'range.disabledBar.color'           => $config['range.disabledBar.color'],
            'range.disabledSubbar.color'        => $config['range.disabledSubbar.color'],
            'range.value.color'                 => $config['range.value.color'],
            'range.value.fontWeight'            => $config['range.value.fontWeight'],
            'range.value.fontSize'              => $config['range.value.fontSize'],
            'range.value.border'                => $config['range.value.border'],
            'range.value.backgroundColor'       => $config['range.value.backgroundColor'],
            'range.title.color'                 => $config['range.title.color'],
            'range.title.fontWeight'            => $config['range.title.fontWeight'],
            'colorpicker.button.border'         => $config['colorpicker.button.border'],
            'colorpicker.title.color'           => $config['colorpicker.title.color']
        ),
    )
);

