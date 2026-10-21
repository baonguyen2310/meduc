-- Original MedUC M mark and outlined wordmark. Custom logos uploaded in admin stay supported.
SET NAMES utf8mb4;
UPDATE settings SET value='/templates/app01/assets/meduc-v2/brand/meduc-logo.svg'
WHERE group_setting='website_info' AND code='company_logo'
AND value LIKE '/templates/app01/assets/meduc-v2/brand/meduc-%';
UPDATE settings SET value='/templates/app01/assets/meduc-v2/brand/meduc-favicon.svg'
WHERE group_setting='website_info' AND code='favicon'
AND value LIKE '/templates/app01/assets/meduc-v2/brand/meduc-%';
UPDATE settings SET value='MedUC'
WHERE group_setting='website_info' AND code LIKE '%website_name' AND value='MedUC Master';
UPDATE templates_page_content SET seo_title='Chính sách bảo mật | MedUC'
WHERE template_code='app01' AND page_code='privacyv3' AND seo_title='Chính sách bảo mật | MedUC Master';
