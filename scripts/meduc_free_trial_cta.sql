-- Rename existing course discovery CTAs without changing their destinations.
SET NAMES utf8mb4;

UPDATE templates_block
SET normal_data_extend = JSON_SET(normal_data_extend, '$.locale.vi.nut_chinh', 'Học thử miễn phí'),
    updated = UNIX_TIMESTAMP()
WHERE template_code = 'app01' AND code = 'herowal'
  AND JSON_UNQUOTE(JSON_EXTRACT(normal_data_extend, '$.locale.vi.nut_chinh'))
      IN ('Khám phá khóa học', 'Khám phá khoá học');

UPDATE templates_block
SET normal_data_extend = JSON_SET(normal_data_extend, '$.locale.vi.nut_phu', 'Học thử miễn phí'),
    updated = UNIX_TIMESTAMP()
WHERE template_code = 'app01' AND code = 'fbhero'
  AND JSON_UNQUOTE(JSON_EXTRACT(normal_data_extend, '$.locale.vi.nut_phu'))
      IN ('Khám phá khóa học', 'Khám phá khoá học');

UPDATE templates_block
SET normal_data_extend = JSON_SET(normal_data_extend, '$.locale.vi.nut_chinh_2', 'Luyện thi miễn phí'),
    updated = UNIX_TIMESTAMP()
WHERE template_code = 'app01' AND code = 'herowal'
  AND JSON_UNQUOTE(JSON_EXTRACT(normal_data_extend, '$.locale.vi.nut_chinh_2'))
      IN ('Vào khoá luyện thi', 'Vào khóa luyện thi');
