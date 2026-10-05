{strip}
<!-- ================= MEDUC OFFICIAL HEADER ================= -->
<header class="sticky top-0 z-50 bg-white shadow-[0_2px_12px_rgba(0,0,0,0.06)] border-b border-slate-100 transition-all font-sans">
  <div class="max-w-7xl mx-auto px-4 sm:px-6">
    <div class="flex items-center justify-between h-20 gap-4">
      
      <!-- MedUC Official Brand Logo -->
      <a href="/" class="flex items-center shrink-0 group py-1" title="MedUC.vn - Học Y Bứt Phá Cùng Th.S - BSNT">
        <img 
          src="https://cdn.meduc.vn/media/core/logo/logo-meduc.png" 
          alt="MedUC.vn - Học Y Bứt Phá Cùng Th.S - BSNT" 
          class="h-10 sm:h-12 w-auto object-contain transition-transform group-hover:scale-102"
          onerror="this.onerror=null; this.src='/templates/app01/assets/img/logo-w500.png';"
        />
      </a>

      <!-- MedUC Desktop Navigation Menu -->
      <nav class="hidden lg:flex items-center gap-1 xl:gap-2 font-bold text-sm text-slate-700">
        
        <!-- Giới thiệu -->
        <a href="/gioi-thieu" class="px-3 py-2 rounded-xl hover:text-medred-600 hover:bg-medred-50/50 transition">
          Giới thiệu
        </a>

        <!-- Phản Hồi -->
        <a href="/phan-hoi-hoc-vien" class="px-3 py-2 rounded-xl hover:text-medred-600 hover:bg-medred-50/50 transition">
          Phản Hồi
        </a>

        <!-- Khóa Học (Dropdown) -->
        <div class="relative group">
          <a href="/khoa-hoc" class="px-3 py-2 rounded-xl hover:text-medred-600 hover:bg-medred-50/50 transition flex items-center gap-1">
            <span>Khóa Học</span>
            <i class="fa-solid fa-chevron-down text-[10px] text-slate-400 group-hover:text-medred-600 group-hover:rotate-180 transition-transform duration-200"></i>
          </a>
          <div class="absolute left-0 top-full pt-2 w-64 invisible opacity-0 translate-y-2 group-hover:visible group-hover:opacity-100 group-hover:translate-y-0 transition-all duration-200 z-50">
            <div class="bg-white rounded-2xl p-2 shadow-xl border border-slate-100 text-xs font-bold space-y-1">
              <a href="/khoa-hoc-sinh-vien-nam-1-nam-2" class="flex items-center gap-2.5 px-3 py-2.5 rounded-xl hover:bg-medred-50 hover:text-medred-600 text-slate-700 transition">
                <i class="fa-solid fa-user-graduate text-slate-400 w-4"></i>
                <span>SV Năm 1 - Năm 2</span>
              </a>
              <a href="/khoa-hoc-sinh-vien-nam-3-nam-4" class="flex items-center gap-2.5 px-3 py-2.5 rounded-xl hover:bg-medred-50 hover:text-medred-600 text-slate-700 transition">
                <i class="fa-solid fa-stethoscope text-slate-400 w-4"></i>
                <span>Sinh Viên Năm 3 - Năm 4</span>
              </a>
              <a href="/khoa-hoc-noi-tru-sau-dai-hoc" class="flex items-center gap-2.5 px-3 py-2.5 rounded-xl hover:bg-medred-50 hover:text-medred-600 text-slate-700 transition">
                <i class="fa-solid fa-hospital-user text-slate-400 w-4"></i>
                <span>Nội Trú - Sau Đại Học</span>
              </a>
              <div class="border-t border-slate-100 pt-1 mt-1">
                <a href="/course-detail" class="flex items-center justify-between px-3 py-2.5 rounded-xl bg-gradient-to-r from-medred-50 to-rose-50 text-medred-700 font-extrabold transition hover:opacity-90">
                  <span class="flex items-center gap-2"><i class="fa-solid fa-crown text-amber-500"></i> Master Ngoại Cơ Sở</span>
                  <span class="text-[10px] px-1.5 py-0.5 rounded bg-medred-600 text-white uppercase">4K Pro</span>
                </a>
              </div>
            </div>
          </div>
        </div>

        <!-- Sách (Dropdown) -->
        <div class="relative group">
          <a href="/sach-y-khoa" class="px-3 py-2 rounded-xl hover:text-medred-600 hover:bg-medred-50/50 transition flex items-center gap-1">
            <span>Sách</span>
            <i class="fa-solid fa-chevron-down text-[10px] text-slate-400 group-hover:text-medred-600 group-hover:rotate-180 transition-transform duration-200"></i>
          </a>
          <div class="absolute left-0 top-full pt-2 w-60 invisible opacity-0 translate-y-2 group-hover:visible group-hover:opacity-100 group-hover:translate-y-0 transition-all duration-200 z-50">
            <div class="bg-white rounded-2xl p-2 shadow-xl border border-slate-100 text-xs font-bold space-y-1">
              <a href="/sach-tieng-anh-y-khoa" class="block px-3 py-2 rounded-xl hover:bg-medred-50 hover:text-medred-600 text-slate-700 transition">Sách Tiếng Anh Y Khoa</a>
              <a href="/sach-ngoai-khoa" class="block px-3 py-2 rounded-xl hover:bg-medred-50 hover:text-medred-600 text-slate-700 transition">Sách Ngoại Khoa</a>
              <a href="/sach-noi-khoa" class="block px-3 py-2 rounded-xl hover:bg-medred-50 hover:text-medred-600 text-slate-700 transition">Sách Nội Khoa</a>
              <a href="/sach-giai-phau" class="block px-3 py-2 rounded-xl hover:bg-medred-50 hover:text-medred-600 text-slate-700 transition">Sách Giải Phẫu</a>
              <a href="/sach-hoa-sinh" class="block px-3 py-2 rounded-xl hover:bg-medred-50 hover:text-medred-600 text-slate-700 transition">Sách Hóa Sinh</a>
              <a href="/sach-sinh-ly" class="block px-3 py-2 rounded-xl hover:bg-medred-50 hover:text-medred-600 text-slate-700 transition">Sách Sinh Lý</a>
            </div>
          </div>
        </div>

        <!-- Tài Liệu (Dropdown) -->
        <div class="relative group">
          <a href="/tai-lieu-hoc-tap" class="px-3 py-2 rounded-xl hover:text-medred-600 hover:bg-medred-50/50 transition flex items-center gap-1">
            <span>Tài Liệu</span>
            <i class="fa-solid fa-chevron-down text-[10px] text-slate-400 group-hover:text-medred-600 group-hover:rotate-180 transition-transform duration-200"></i>
          </a>
          <div class="absolute left-0 top-full pt-2 w-52 invisible opacity-0 translate-y-2 group-hover:visible group-hover:opacity-100 group-hover:translate-y-0 transition-all duration-200 z-50">
            <div class="bg-white rounded-2xl p-2 shadow-xl border border-slate-100 text-xs font-bold space-y-1">
              <a href="/y-khoa-nam-1" class="block px-3 py-2 rounded-xl hover:bg-medred-50 hover:text-medred-600 text-slate-700 transition">Y Khoa Năm 1</a>
              <a href="/y-khoa-nam-2" class="block px-3 py-2 rounded-xl hover:bg-medred-50 hover:text-medred-600 text-slate-700 transition">Y Khoa Năm 2</a>
              <a href="/y-khoa-nam-3" class="block px-3 py-2 rounded-xl hover:bg-medred-50 hover:text-medred-600 text-slate-700 transition">Y Khoa Năm 3</a>
              <a href="/y-khoa-nam-4" class="block px-3 py-2 rounded-xl hover:bg-medred-50 hover:text-medred-600 text-slate-700 transition">Y Khoa Năm 4</a>
            </div>
          </div>
        </div>

        <!-- Đề Thi (Dropdown + Hot Badge) -->
        <div class="relative group">
          <a href="/danh-sach-de-thi" class="px-3 py-2 rounded-xl hover:text-medred-600 hover:bg-medred-50/50 transition flex items-center gap-1">
            <span>Đề Thi</span>
            <span class="text-[9px] font-black px-1.5 py-0.5 rounded-full bg-orange-500 text-white leading-none">HOT</span>
            <i class="fa-solid fa-chevron-down text-[10px] text-slate-400 group-hover:text-medred-600 group-hover:rotate-180 transition-transform duration-200"></i>
          </a>
          <div class="absolute left-0 top-full pt-2 w-64 invisible opacity-0 translate-y-2 group-hover:visible group-hover:opacity-100 group-hover:translate-y-0 transition-all duration-200 z-50">
            <div class="bg-white rounded-2xl p-2 shadow-xl border border-slate-100 text-xs font-bold space-y-1">
              <a href="/medduo" class="flex items-center justify-between px-3 py-2.5 rounded-xl bg-orange-50 text-orange-700 font-black transition hover:bg-orange-100">
                <span class="flex items-center gap-2"><i class="fa-solid fa-fire text-orange-500"></i> MedDuo (713 Bộ Đề)</span>
                <span class="text-[10px] px-1.5 py-0.5 rounded bg-orange-500 text-white">DUO</span>
              </a>
              <div class="border-t border-slate-100 pt-1"></div>
              <a href="/de-thi-tieng-anh-y-khoa" class="block px-3 py-2 rounded-xl hover:bg-medred-50 hover:text-medred-600 text-slate-700 transition">Đề thi Tiếng Anh Y Khoa</a>
              <a href="/de-thi-ngoai-khoa" class="block px-3 py-2 rounded-xl hover:bg-medred-50 hover:text-medred-600 text-slate-700 transition">Đề thi Ngoại Khoa</a>
              <a href="/de-thi-noi-khoa" class="block px-3 py-2 rounded-xl hover:bg-medred-50 hover:text-medred-600 text-slate-700 transition">Đề thi Nội Khoa</a>
              <a href="/de-thi-giai-phau" class="block px-3 py-2 rounded-xl hover:bg-medred-50 hover:text-medred-600 text-slate-700 transition">Đề thi Giải Phẫu</a>
              <a href="/de-thi-hoa-sinh" class="block px-3 py-2 rounded-xl hover:bg-medred-50 hover:text-medred-600 text-slate-700 transition">Đề thi Hoá Sinh</a>
              <a href="/de-thi-sinh-ly" class="block px-3 py-2 rounded-xl hover:bg-medred-50 hover:text-medred-600 text-slate-700 transition">Đề thi Sinh Lý</a>
            </div>
          </div>
        </div>

        <!-- Kinh Nghiệm / Blog (Dropdown) -->
        <div class="relative group">
          <a href="/blog" class="px-3 py-2 rounded-xl hover:text-medred-600 hover:bg-medred-50/50 transition flex items-center gap-1">
            <span>Kinh Nghiệm</span>
            <i class="fa-solid fa-chevron-down text-[10px] text-slate-400 group-hover:text-medred-600 group-hover:rotate-180 transition-transform duration-200"></i>
          </a>
          <div class="absolute right-0 lg:left-0 top-full pt-2 w-64 invisible opacity-0 translate-y-2 group-hover:visible group-hover:opacity-100 group-hover:translate-y-0 transition-all duration-200 z-50">
            <div class="bg-white rounded-2xl p-2 shadow-xl border border-slate-100 text-xs font-bold space-y-1">
              <a href="/article-detail" class="flex items-center justify-between px-3 py-2.5 rounded-xl bg-rose-50 text-medred-700 font-black transition hover:bg-rose-100">
                <span class="flex items-center gap-2"><i class="fa-solid fa-newspaper text-medred-600"></i> Ca Lâm Sàng & ECG</span>
                <span class="text-[10px] px-1.5 py-0.5 rounded bg-medred-600 text-white">Mới</span>
              </a>
              <div class="border-t border-slate-100 pt-1"></div>
              <a href="/blog-kinh-nghiem" class="block px-3 py-2 rounded-xl hover:bg-medred-50 hover:text-medred-600 text-slate-700 transition">Blog Kinh Nghiệm</a>
              <a href="/blog-tieng-anh-y-khoa" class="block px-3 py-2 rounded-xl hover:bg-medred-50 hover:text-medred-600 text-slate-700 transition">Blog Tiếng Anh Y Khoa</a>
              <a href="/blog-ngoai-khoa" class="block px-3 py-2 rounded-xl hover:bg-medred-50 hover:text-medred-600 text-slate-700 transition">Blog Ngoại Khoa</a>
              <a href="/blog-noi-khoa" class="block px-3 py-2 rounded-xl hover:bg-medred-50 hover:text-medred-600 text-slate-700 transition">Blog Nội Khoa</a>
              <a href="/blog-giai-phau" class="block px-3 py-2 rounded-xl hover:bg-medred-50 hover:text-medred-600 text-slate-700 transition">Blog Giải Phẫu</a>
            </div>
          </div>
        </div>

      </nav>

      <!-- Right Side Utility Icons (Matching MedUC) -->
      <div class="flex items-center gap-1.5 sm:gap-2 shrink-0">
        
        <!-- Search trigger -->
        <div class="relative">
          <button onclick="toggleHeaderSearch()" class="w-10 h-10 rounded-xl hover:bg-slate-100 text-slate-600 hover:text-medred-600 transition flex items-center justify-center text-base" title="Tìm kiếm">
            <i class="fa-solid fa-magnifying-glass"></i>
          </button>
          <div id="header-search-bar" class="hidden absolute right-0 top-12 w-72 sm:w-80 bg-white rounded-2xl p-2.5 shadow-2xl border border-slate-200 z-50">
            <form action="/tim-kiem" method="GET" class="flex items-center gap-2">
              <input 
                type="text" 
                name="keyword" 
                placeholder="Tìm khóa học, sách, đề thi..." 
                class="w-full px-3.5 py-2 text-xs font-bold rounded-xl bg-slate-50 border border-slate-200 focus:outline-none focus:border-medred-600"
              />
              <button type="submit" class="px-3 py-2 rounded-xl bg-medred-600 text-white text-xs font-bold hover:bg-medred-700 transition">
                <i class="fa-solid fa-arrow-right"></i>
              </button>
            </form>
          </div>
        </div>

        <!-- Giỏ hàng Sách & Thiết bị -->
        <a href="/dat-hang" class="relative w-10 h-10 rounded-xl hover:bg-slate-100 text-slate-600 hover:text-medred-600 transition flex items-center justify-center text-base" title="Giỏ hàng Sách và Thiết bị">
          <i class="fa-solid fa-cart-shopping"></i>
          <span class="absolute top-1.5 right-1.5 w-4 h-4 bg-slate-700 text-white rounded-full text-[9px] font-black flex items-center justify-center leading-none">0</span>
        </a>

        <!-- Giỏ hàng Khóa học -->
        <a href="/checkout-v2" class="relative w-10 h-10 rounded-xl hover:bg-slate-100 text-slate-600 hover:text-medred-600 transition flex items-center justify-center text-base" title="Giỏ hàng Khóa học">
          <i class="fa-solid fa-bag-shopping"></i>
          <span class="absolute top-1.5 right-1.5 w-4 h-4 bg-medred-600 text-white rounded-full text-[9px] font-black flex items-center justify-center leading-none">1</span>
        </a>

        <!-- Cổng Học Viên / Tài Khoản -->
        <a href="/portal" class="flex items-center gap-2 pl-2 pr-3.5 py-1.5 rounded-full bg-slate-50 hover:bg-medred-50 border border-slate-200 hover:border-medred-200 text-slate-700 hover:text-medred-700 transition text-xs font-bold ml-1 shadow-sm" title="Cổng Học Viên MedUC">
          <div class="w-7 h-7 rounded-full bg-gradient-to-tr from-medred-600 to-rose-500 text-white flex items-center justify-center text-xs font-black shadow-sm">
            <i class="fa-solid fa-user"></i>
          </div>
          <span class="hidden sm:inline">Học Viên</span>
        </a>

        <!-- Mobile Hamburger Menu Button -->
        <button onclick="toggleMobileNav()" class="lg:hidden w-10 h-10 rounded-xl hover:bg-slate-100 text-slate-700 hover:text-medred-600 transition flex items-center justify-center text-lg ml-1" title="Menu">
          <i class="fa-solid fa-bars"></i>
        </button>

      </div>

    </div>
  </div>

  <!-- Mobile Slide-Down Navigation Drawer -->
  <div id="mobile-nav-drawer" class="hidden lg:hidden border-t border-slate-100 bg-white px-4 py-5 shadow-2xl max-h-[80vh] overflow-y-auto">
    <div class="space-y-3 text-sm font-bold text-slate-800">
      <a href="/gioi-thieu" class="block py-2 px-3 rounded-xl hover:bg-slate-50">Giới thiệu</a>
      <a href="/phan-hoi-hoc-vien" class="block py-2 px-3 rounded-xl hover:bg-slate-50">Phản Hồi</a>
      
      <!-- Khóa Học Mobile -->
      <div class="py-1">
        <div class="px-3 py-1 text-xs font-black text-slate-400 uppercase tracking-wider">Khóa Học</div>
        <a href="/khoa-hoc-sinh-vien-nam-1-nam-2" class="block py-2 px-4 rounded-xl hover:bg-medred-50 hover:text-medred-600">SV Năm 1 - Năm 2</a>
        <a href="/khoa-hoc-sinh-vien-nam-3-nam-4" class="block py-2 px-4 rounded-xl hover:bg-medred-50 hover:text-medred-600">Sinh Viên Năm 3 - Năm 4</a>
        <a href="/khoa-hoc-noi-tru-sau-dai-hoc" class="block py-2 px-4 rounded-xl hover:bg-medred-50 hover:text-medred-600">Nội Trú - Sau Đại Học</a>
        <a href="/course-detail" class="block py-2 px-4 rounded-xl text-medred-600 font-black bg-medred-50/60 mt-1">★ Khóa Master Ngoại Cơ Sở</a>
      </div>

      <!-- Sách Mobile -->
      <div class="py-1">
        <div class="px-3 py-1 text-xs font-black text-slate-400 uppercase tracking-wider">Sách Y Khoa</div>
        <a href="/sach-tieng-anh-y-khoa" class="block py-2 px-4 rounded-xl hover:bg-slate-50">Sách Tiếng Anh Y Khoa</a>
        <a href="/sach-ngoai-khoa" class="block py-2 px-4 rounded-xl hover:bg-slate-50">Sách Ngoại Khoa</a>
        <a href="/sach-noi-khoa" class="block py-2 px-4 rounded-xl hover:bg-slate-50">Sách Nội Khoa</a>
        <a href="/sach-giai-phau" class="block py-2 px-4 rounded-xl hover:bg-slate-50">Sách Giải Phẫu</a>
      </div>

      <!-- Tài Liệu Mobile -->
      <div class="py-1">
        <div class="px-3 py-1 text-xs font-black text-slate-400 uppercase tracking-wider">Tài Liệu Học Tập</div>
        <a href="/y-khoa-nam-1" class="block py-2 px-4 rounded-xl hover:bg-slate-50">Y Khoa Năm 1</a>
        <a href="/y-khoa-nam-2" class="block py-2 px-4 rounded-xl hover:bg-slate-50">Y Khoa Năm 2</a>
        <a href="/y-khoa-nam-3" class="block py-2 px-4 rounded-xl hover:bg-slate-50">Y Khoa Năm 3</a>
        <a href="/y-khoa-nam-4" class="block py-2 px-4 rounded-xl hover:bg-slate-50">Y Khoa Năm 4</a>
      </div>

      <!-- Đề Thi Mobile -->
      <div class="py-1">
        <div class="px-3 py-1 text-xs font-black text-slate-400 uppercase tracking-wider">Đề Thi & Luyện Trắc Nghiệm</div>
        <a href="/medduo" class="block py-2.5 px-4 rounded-xl bg-orange-50 text-orange-700 font-black mb-1">🔥 Cổng Luyện Đề MedDuo (713 Đề)</a>
        <a href="/de-thi-ngoai-khoa" class="block py-2 px-4 rounded-xl hover:bg-slate-50">Đề thi Ngoại Khoa</a>
        <a href="/de-thi-noi-khoa" class="block py-2 px-4 rounded-xl hover:bg-slate-50">Đề thi Nội Khoa</a>
        <a href="/de-thi-giai-phau" class="block py-2 px-4 rounded-xl hover:bg-slate-50">Đề thi Giải Phẫu</a>
      </div>

      <!-- Kinh Nghiệm Mobile -->
      <div class="py-1">
        <div class="px-3 py-1 text-xs font-black text-slate-400 uppercase tracking-wider">Kinh Nghiệm & Tạp Chí</div>
        <a href="/article-detail" class="block py-2.5 px-4 rounded-xl bg-medred-50 text-medred-700 font-black mb-1">🩺 Đọc Ca Lâm Sàng & ECG</a>
        <a href="/blog-kinh-nghiem" class="block py-2 px-4 rounded-xl hover:bg-slate-50">Blog Kinh Nghiệm</a>
      </div>

      <div class="pt-3 border-t border-slate-100 flex items-center justify-between">
        <a href="/portal" class="flex items-center gap-2 py-2 px-4 rounded-xl bg-medred-600 text-white font-bold text-xs w-full justify-center">
          <i class="fa-solid fa-user"></i> Cổng Học Viên MedUC
        </a>
      </div>

    </div>
  </div>
</header>
{/strip}
