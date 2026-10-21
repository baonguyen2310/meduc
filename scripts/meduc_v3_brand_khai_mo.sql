-- Selected logo option 02 (Khai mo). Custom uploads in admin remain supported.
SET NAMES utf8mb4;
UPDATE settings SET value='/templates/app01/assets/meduc-v2/brand/meduc-khai-mo.svg'
WHERE group_setting='website_info' AND code='company_logo'
AND value IN ('/templates/app01/assets/meduc-v2/brand/meduc-logo.svg','/templates/app01/assets/meduc-v2/brand/meduc-khai-mo.svg');
UPDATE settings SET value='/templates/app01/assets/meduc-v2/brand/meduc-khai-mo-favicon.svg'
WHERE group_setting='website_info' AND code='favicon'
AND value IN ('/templates/app01/assets/meduc-v2/brand/meduc-favicon.svg','/templates/app01/assets/meduc-v2/brand/meduc-khai-mo-favicon.svg');
