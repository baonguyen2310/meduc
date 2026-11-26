{$meduc_catalog_groups = [
  'academy' => [
    'label' => 'MedUC Academy', 'icon' => 'users',
    'items' => [
      ['url' => '/khoa-hoc', 'label' => 'Khoá ôn kiến thức', 'icon' => 'book'],
      ['url' => '/khoa-chua-de', 'label' => 'Khoá luyện thi', 'icon' => 'pulse']
    ]
  ],
  'library' => [
    'label' => 'MedUC Library', 'icon' => 'journal',
    'items' => [
      'documents' => ['url' => '/tai-lieu-hoc-tap', 'label' => 'Tài liệu', 'icon' => 'document'],
      'quiz' => ['url' => '/trac-nghiem', 'label' => 'Đề thi', 'icon' => 'journal'],
      'blog' => ['url' => '/blog', 'label' => 'Blog', 'icon' => 'book']
    ]
  ],
  'shop' => [
    'label' => 'MedUC Shop', 'icon' => 'store',
    'items' => [
      ['url' => '/sach-y-khoa', 'label' => 'Sách', 'icon' => 'book'],
      ['url' => '/thiet-bi-y-te', 'label' => 'Thiết bị y tế', 'icon' => 'pulse'],
      ['url' => '/ao-blouse', 'label' => 'Áo blouse', 'icon' => 'coat']
    ]
  ]
]}
