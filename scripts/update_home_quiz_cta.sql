-- Homepage CTA stays editable in the block's localized content.
UPDATE templates_block
SET normal_data_extend = JSON_SET(normal_data_extend,
    '$.locale.vi.nut_chinh_2', 'Trắc nghiệm miễn phí',
    '$.locale.vi.link_nut_chinh_2', '/trac-nghiem')
WHERE template_code = 'app01' AND code = 'herowal' AND view = 'view_hero_wall.tpl';
