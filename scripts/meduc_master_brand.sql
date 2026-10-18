-- MedUC Master brand assets are versioned with the template; normal Admin uploads remain supported.
-- Logo/favicons use the existing website settings. This does not change the legal company name or contact details.
SET NAMES utf8mb4;
START TRANSACTION;
UPDATE settings SET value='/templates/app01/assets/meduc-v2/brand/meduc-master-v2.svg'
 WHERE group_setting='website_info' AND code='company_logo' AND value IN ('/media/core/logo/logo-meduc.png','/templates/app01/assets/meduc-v2/brand/meduc-master.svg');
UPDATE settings SET value='/templates/app01/assets/meduc-v2/brand/meduc-master-favicon-v2.svg'
 WHERE group_setting='website_info' AND code='favicon' AND value IN ('/media/core/logo/logo-meduc.png','/templates/app01/assets/meduc-v2/brand/meduc-master-favicon.svg');
UPDATE settings SET value='MedUC Master'
 WHERE group_setting='website_info' AND code='vi_website_name' AND value='MedUC.vn - Học Y Bứt Phá Cùng Th.S - BSNT';
COMMIT;
