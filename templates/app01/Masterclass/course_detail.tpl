<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Ngoại Cơ Sở & Khám Bệnh Ngoại Khoa Thực Chiến - MedUC MasterClass</title>
  
  <!-- Tailwind CSS CDN -->
  <script src="https://cdn.tailwindcss.com"></script>
  {literal}
  <script>
    tailwind.config = {
      theme: {
        extend: {
          colors: {
            medred: {
              50: '#fff1f2',
              100: '#ffe4e6',
              200: '#fecdd3',
              400: '#fb7185',
              500: '#f43f5e',
              600: '#e11d48',
              700: '#be123c',
              800: '#9f1239',
              900: '#881337',
            },
            medorange: {
              500: '#f35925',
              600: '#ea580c',
            }
          },
          fontFamily: {
            sans: ['"Plus Jakarta Sans"', 'system-ui', '-apple-system', 'sans-serif'],
          }
        }
      }
    }
  </script>
  {/literal}

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

  {literal}
  <style>
    body {
      font-family: 'Plus Jakarta Sans', sans-serif;
      background-color: #ffffff;
      color: #0f172a;
    }
    .sticky-card {
      position: sticky;
      top: 6rem;
    }
  </style>
  {/literal}
</head>
<body class="antialiased min-h-screen flex flex-col selection:bg-medred-100 selection:text-medred-700 bg-white">

  <!-- ================= MEDUC OFFICIAL HEADER ================= -->
  {$this->element('layout/header_meduc')}

  <!-- ================= HERO COURSE BANNER ================= -->
  <section class="bg-gradient-to-b from-slate-900 via-slate-950 to-slate-900 text-white py-12 md:py-16 relative overflow-hidden">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 relative z-10">
      
      <!-- Breadcrumbs -->
      <nav class="flex items-center gap-2 text-xs font-bold text-slate-400 mb-4">
        <a href="/masterclass" class="hover:text-white transition">Trang Chủ</a>
        <span>/</span>
        <a href="/masterclass#courses-section" class="hover:text-white transition">Ngoại Khoa</a>
        <span>/</span>
        <span class="text-medred-400">Ngoại Cơ Sở</span>
      </nav>

      <div class="max-w-3xl">
        <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-medred-600/20 text-medred-400 border border-medred-500/30 text-xs font-black uppercase tracking-wider mb-4">
          <i class="fa-solid fa-crown text-amber-400"></i> KHÓA HỌC FLAGSHIP • 4K CLINICAL VIDEO
        </div>

        <h1 class="text-3xl sm:text-5xl font-black text-white tracking-tight leading-tight mb-4">
          Ngoại Cơ Sở & Khám Bệnh Ngoại Khoa Thực Chiến
        </h1>

        <p class="text-sm sm:text-base text-slate-300 font-medium leading-relaxed mb-6">
          Thành thạo toàn diện kỹ năng khám bụng cấp cứu, chẩn đoán sớm viêm ruột thừa, tắc ruột, viêm túi mật cấp, thoát vị bẹn và làm chủ các trạm thi chạy trạm OSCE ngoại khoa điểm 9+.
        </p>

        <!-- Meta Ratings & Stats -->
        <div class="flex flex-wrap items-center gap-4 sm:gap-6 text-xs font-extrabold text-slate-300 pt-2 border-t border-slate-800">
          <div class="flex items-center gap-1 text-amber-400">
            <i class="fa-solid fa-star"></i>
            <span class="text-white font-black">4.98</span>
            <span class="text-slate-400 font-normal">(3.420 đánh giá)</span>
          </div>
          <div class="flex items-center gap-1.5">
            <i class="fa-solid fa-users text-medred-400"></i>
            <span>4.850+ Học viên đã học</span>
          </div>
          <div class="flex items-center gap-1.5">
            <i class="fa-solid fa-circle-play text-medred-400"></i>
            <span>24 Bài học • 12 Giờ Video 4K</span>
          </div>
          <div class="flex items-center gap-1.5">
            <i class="fa-solid fa-book-bookmark text-medred-400"></i>
            <span>Tặng Sách In Màu A5 Gửi Tận Tay</span>
          </div>
        </div>
      </div>

    </div>
  </section>

  <!-- ================= MAIN CONTENT 2-COLUMNS ================= -->
  <main class="max-w-7xl mx-auto px-4 sm:px-6 py-12 flex-1 w-full">
    <div class="flex flex-col lg:flex-row gap-10 items-start">
      
      <!-- LEFT COLUMN: COURSE DETAILS & SYLLABUS (70%) -->
      <div class="flex-1 min-w-0 w-full space-y-12">
        
        <!-- Video Trailer Container -->
        <div class="rounded-3xl overflow-hidden shadow-xl border border-slate-200 relative aspect-video bg-slate-900 group">
          <img 
            src="https://images.unsplash.com/photo-1551076805-e1869033e561?w=1200&auto=format&fit=crop&q=80" 
            alt="Trailer Ngoại Cơ Sở" 
            class="w-full h-full object-cover opacity-80 group-hover:scale-105 transition duration-500"
          />
          <div class="absolute inset-0 bg-gradient-to-t from-slate-950 via-slate-950/40 to-transparent flex flex-col items-center justify-center p-6 text-center">
            <div class="w-20 h-20 rounded-full bg-medred-600 text-white flex items-center justify-center text-3xl shadow-2xl mb-4 group-hover:scale-110 transition cursor-pointer">
              <i class="fa-solid fa-play ml-1.5"></i>
            </div>
            <span class="text-xs font-black uppercase tracking-widest text-slate-200">XEM BÀI GIẢNG HỌC THỬ MIỄN PHÍ (BÀI 1: KHÁM BỤNG CẤP CỨU)</span>
          </div>
        </div>

        <!-- 1. What you will learn (Key Outcomes) -->
        <div class="p-8 rounded-3xl bg-slate-50 border border-slate-200/90">
          <h2 class="text-xl font-black text-slate-950 mb-5 flex items-center gap-2">
            <i class="fa-solid fa-graduation-cap text-medred-600"></i>
            <span>Bạn Sẽ Làm Chủ Được Gì Sau Khóa Học?</span>
          </h2>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs font-bold text-slate-700">
            <div class="flex items-start gap-3">
              <i class="fa-solid fa-circle-check text-emerald-600 text-base shrink-0 mt-0.5"></i>
              <span>Kỹ thuật nhìn - sờ - gõ - nghe bụng chuẩn xác, phân biệt phản ứng thành bụng và co cứng như gỗ.</span>
            </div>
            <div class="flex items-start gap-3">
              <i class="fa-solid fa-circle-check text-emerald-600 text-base shrink-0 mt-0.5"></i>
              <span>Làm chủ các điểm đau ngoại khoa: MacBurney, Murphy, Mayo-Robson, điểm niệu quản.</span>
            </div>
            <div class="flex items-start gap-3">
              <i class="fa-solid fa-circle-check text-emerald-600 text-base shrink-0 mt-0.5"></i>
              <span>Khám và chẩn đoán phân biệt thoát vị bẹn nghẹt với tràn dịch màng tinh hoàn, viêm tinh hoàn.</span>
            </div>
            <div class="flex items-start gap-3">
              <i class="fa-solid fa-circle-check text-emerald-600 text-base shrink-0 mt-0.5"></i>
              <span>Thăm khám chấn thương bụng kín, phát hiện sớm vỡ lách, vỡ gan gây sốc mất máu.</span>
            </div>
            <div class="flex items-start gap-3">
              <i class="fa-solid fa-circle-check text-emerald-600 text-base shrink-0 mt-0.5"></i>
              <span>Quy trình làm bệnh án ngoại khoa và bảo vệ bệnh án trước ban giám khảo thi tốt nghiệp.</span>
            </div>
            <div class="flex items-start gap-3">
              <i class="fa-solid fa-circle-check text-emerald-600 text-base shrink-0 mt-0.5"></i>
              <span>Bộ 300 câu hỏi trắc nghiệm ngoại khoa MedDuo có giải thích bệnh học từng câu.</span>
            </div>
          </div>
        </div>

        <!-- 2. Course Syllabus (Curriculum Accordion) -->
        <div>
          <div class="flex items-center justify-between mb-6">
            <div>
              <span class="text-xs font-black uppercase tracking-widest text-medred-600">LỘ TRÌNH ĐÀO TẠO</span>
              <h2 class="text-2xl font-black text-slate-950 mt-1">Nội Dung 24 Bài Giảng</h2>
            </div>
            <span class="text-xs font-extrabold text-slate-400">4 Phần • 24 Bài học • 12 Giờ</span>
          </div>

          <div class="space-y-4">
            
            <!-- Module 1 -->
            <div class="rounded-2xl border border-slate-200 overflow-hidden bg-white shadow-sm">
              <div class="p-5 bg-slate-50/80 border-b border-slate-200 flex items-center justify-between cursor-pointer">
                <div class="flex items-center gap-3">
                  <span class="w-8 h-8 rounded-xl bg-medred-100 text-medred-700 text-xs font-black flex items-center justify-center">01</span>
                  <div>
                    <h3 class="font-black text-slate-900 text-sm">Phần 1: Khám Bụng Cấp Cứu & Triệu Chứng Học Cơ Bản</h3>
                    <p class="text-[11px] font-bold text-slate-400 mt-0.5">6 bài học • 3 giờ 15 phút</p>
                  </div>
                </div>
                <i class="fa-solid fa-chevron-down text-slate-400 text-xs"></i>
              </div>
              <div class="p-4 space-y-2.5 text-xs font-bold text-slate-600">
                <div class="flex items-center justify-between p-2 rounded-xl hover:bg-slate-50 transition">
                  <span class="flex items-center gap-2"><i class="fa-solid fa-play text-medred-600 text-[10px]"></i> Bài 1: Đại cương và phân chia 9 vùng ổ bụng lâm sàng</span>
                  <span class="px-2 py-0.5 rounded-full text-[10px] font-black bg-emerald-100 text-emerald-700">Học Thử</span>
                </div>
                <div class="flex items-center justify-between p-2 rounded-xl hover:bg-slate-50 transition">
                  <span class="flex items-center gap-2"><i class="fa-solid fa-play text-slate-400 text-[10px]"></i> Bài 2: Kỹ năng nhìn và nghe nhu động ruột trong tắc ruột cơ học</span>
                  <span class="text-slate-400">28 phút</span>
                </div>
                <div class="flex items-center justify-between p-2 rounded-xl hover:bg-slate-50 transition">
                  <span class="flex items-center gap-2"><i class="fa-solid fa-play text-slate-400 text-[10px]"></i> Bài 3: Sờ bụng: Cảm ứng phúc mạc vs Phản ứng thành bụng</span>
                  <span class="text-slate-400">35 phút</span>
                </div>
                <div class="flex items-center justify-between p-2 rounded-xl hover:bg-slate-50 transition">
                  <span class="flex items-center gap-2"><i class="fa-solid fa-play text-slate-400 text-[10px]"></i> Bài 4: Gõ đục vùng thấp và mất vùng đục trước gan trong thủng tạng rỗng</span>
                  <span class="text-slate-400">22 phút</span>
                </div>
              </div>
            </div>

            <!-- Module 2 -->
            <div class="rounded-2xl border border-slate-200 overflow-hidden bg-white shadow-sm">
              <div class="p-5 bg-slate-50/80 border-b border-slate-200 flex items-center justify-between cursor-pointer">
                <div class="flex items-center gap-3">
                  <span class="w-8 h-8 rounded-xl bg-medred-100 text-medred-700 text-xs font-black flex items-center justify-center">02</span>
                  <div>
                    <h3 class="font-black text-slate-900 text-sm">Phần 2: Các Bệnh Cảnh Cấp Cứu Ngoại Tiêu Hóa Thường Gặp</h3>
                    <p class="text-[11px] font-bold text-slate-400 mt-0.5">8 bài học • 4 giờ 20 phút</p>
                  </div>
                </div>
                <i class="fa-solid fa-chevron-down text-slate-400 text-xs"></i>
              </div>
              <div class="p-4 space-y-2.5 text-xs font-bold text-slate-600">
                <div class="flex items-center justify-between p-2 rounded-xl hover:bg-slate-50 transition">
                  <span class="flex items-center gap-2"><i class="fa-solid fa-play text-slate-400 text-[10px]"></i> Bài 5: Viêm ruột thừa cấp: Tiếp cận từ thể điển hình đến vị trí bất thường</span>
                  <span class="text-slate-400">42 phút</span>
                </div>
                <div class="flex items-center justify-between p-2 rounded-xl hover:bg-slate-50 transition">
                  <span class="flex items-center gap-2"><i class="fa-solid fa-play text-slate-400 text-[10px]"></i> Bài 6: Hội chứng tắc ruột cơ học: Dấu hiệu rắn bò và quai ruột nổi</span>
                  <span class="text-slate-400">38 phút</span>
                </div>
                <div class="flex items-center justify-between p-2 rounded-xl hover:bg-slate-50 transition">
                  <span class="flex items-center gap-2"><i class="fa-solid fa-play text-slate-400 text-[10px]"></i> Bài 7: Thủng ổ loét dạ dày - tá tràng: Bụng cứng như gỗ và liềm hơi dưới hoành</span>
                  <span class="text-slate-400">32 phút</span>
                </div>
              </div>
            </div>

            <!-- Module 3 -->
            <div class="rounded-2xl border border-slate-200 overflow-hidden bg-white shadow-sm">
              <div class="p-5 bg-slate-50/80 border-b border-slate-200 flex items-center justify-between cursor-pointer">
                <div class="flex items-center gap-3">
                  <span class="w-8 h-8 rounded-xl bg-medred-100 text-medred-700 text-xs font-black flex items-center justify-center">03</span>
                  <div>
                    <h3 class="font-black text-slate-900 text-sm">Phần 3: Thoát Vị Thành Bụng & Bệnh Lý Hậu Môn - Trực Tràng</h3>
                    <p class="text-[11px] font-bold text-slate-400 mt-0.5">5 bài học • 2 giờ 40 phút</p>
                  </div>
                </div>
                <i class="fa-solid fa-chevron-down text-slate-400 text-xs"></i>
              </div>
            </div>

            <!-- Module 4 -->
            <div class="rounded-2xl border border-slate-200 overflow-hidden bg-white shadow-sm">
              <div class="p-5 bg-slate-50/80 border-b border-slate-200 flex items-center justify-between cursor-pointer">
                <div class="flex items-center gap-3">
                  <span class="w-8 h-8 rounded-xl bg-medred-100 text-medred-700 text-xs font-black flex items-center justify-center">04</span>
                  <div>
                    <h3 class="font-black text-slate-900 text-sm">Phần 4: Kỹ Năng Làm Bệnh Án Ngoại Khoa & Trạm Thi OSCE</h3>
                    <p class="text-[11px] font-bold text-slate-400 mt-0.5">5 bài học • 2 giờ 30 phút</p>
                  </div>
                </div>
                <i class="fa-solid fa-chevron-down text-slate-400 text-xs"></i>
              </div>
            </div>

          </div>
        </div>

        <!-- 3. Instructor Profile -->
        <div class="p-8 rounded-3xl bg-slate-50 border border-slate-200/90 flex flex-col sm:flex-row gap-6 items-start">
          <img 
            src="https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=400&auto=format&fit=crop&q=80" 
            alt="TS.BS CKII Nguyễn Văn An" 
            class="w-24 h-24 sm:w-28 sm:h-28 rounded-2xl object-cover border-2 border-medred-200 shadow-md shrink-0"
          />
          <div>
            <div class="flex items-center gap-2">
              <span class="text-[11px] font-black uppercase text-medred-600">GIẢNG VIÊN ĐỨNG LỚP</span>
              <span class="text-xs text-slate-400">• 20 Năm Kinh Nghiệm</span>
            </div>
            <h3 class="text-xl font-black text-slate-950 mt-1 mb-2">TS.BS CKII Nguyễn Văn An</h3>
            <p class="text-xs font-bold text-slate-500 mb-3">Trưởng khoa Ngoại Tiêu Hóa • Bác sĩ Phẫu thuật Nội soi Cấp cứu</p>
            <p class="text-xs text-slate-600 leading-relaxed font-medium">
              "Khóa học này đúc kết toàn bộ những lỗi sai mà sinh viên Y và các bác sĩ nội trú năm nhất hay mắc phải khi trực cấp cứu. Mục tiêu của tôi là giúp bạn tự tin đặt tay lên bụng bệnh nhân và ra quyết định xử trí chuẩn xác."
            </p>
          </div>
        </div>

      </div>

      <!-- RIGHT COLUMN: STICKY PURCHASE CARD (30%) -->
      <aside class="w-full lg:w-96 shrink-0 sticky-card">
        <div class="bg-white rounded-3xl p-6 border-2 border-slate-200 shadow-xl space-y-6">
          
          <!-- Pricing -->
          <div>
            <div class="flex items-center justify-between mb-1">
              <span class="px-2.5 py-0.5 rounded-full text-[10px] font-black uppercase tracking-wider bg-medred-100 text-medred-700">
                Ưu Đãi Đặc Quyền
              </span>
              <span class="text-xs font-bold text-slate-400 line-through">4.500.000đ</span>
            </div>
            <div class="text-3xl sm:text-4xl font-black text-medred-600 tracking-tight">
              3.000.000đ
            </div>
            <p class="text-[11px] font-bold text-emerald-600 mt-1 flex items-center gap-1">
              <i class="fa-solid fa-clock"></i> Tiết kiệm 1.500.000đ • Ưu đãi còn 2 ngày
            </p>
          </div>

          <!-- Primary CTA Button -->
          <div class="space-y-2.5">
            <a href="/checkout-v2" class="w-full py-4 rounded-2xl bg-medred-600 hover:bg-medred-700 text-white font-black text-sm text-center shadow-lg shadow-medred-600/25 transition transform hover:-translate-y-0.5 flex items-center justify-center gap-2">
              <span>ĐĂNG KÝ HỌC NGAY</span>
              <i class="fa-solid fa-arrow-right text-xs"></i>
            </a>
            <button onclick="alert('Đang mở video bài 1 học thử miễn phí...')" class="w-full py-3 rounded-2xl border-2 border-slate-200 text-slate-700 font-black text-xs hover:bg-slate-50 transition">
              <i class="fa-solid fa-play text-medred-600 mr-1.5"></i> Học Thử Bài 1 Miễn Phí
            </button>
          </div>

          <!-- Inclusions Checklist -->
          <div class="pt-5 border-t border-slate-100 space-y-3 text-xs font-bold text-slate-700">
            <div class="text-xs font-black uppercase tracking-wider text-slate-400 mb-2">Đặc quyền khóa học gồm:</div>
            <div class="flex items-center gap-2.5">
              <i class="fa-solid fa-book text-medred-600"></i>
              <span>Tặng Sách In Màu A5 (180 trang) gửi tận nhà</span>
            </div>
            <div class="flex items-center gap-2.5">
              <i class="fa-solid fa-infinity text-medred-600"></i>
              <span>Xem bài giảng 4K trọn đời trên Web & App</span>
            </div>
            <div class="flex items-center gap-2.5">
              <i class="fa-solid fa-fire text-orange-500"></i>
              <span>300+ Câu trắc nghiệm ngoại khoa MedDuo</span>
            </div>
            <div class="flex items-center gap-2.5">
              <i class="fa-solid fa-user-doctor text-medred-600"></i>
              <span>Hỏi đáp ca bệnh cùng Bác sĩ 24/7</span>
            </div>
            <div class="flex items-center gap-2.5">
              <i class="fa-solid fa-certificate text-amber-500"></i>
              <span>Cấp Chứng chỉ hoàn thành từ MedUC</span>
            </div>
          </div>

          <!-- Guarantee Badge -->
          <div class="p-4 rounded-2xl bg-slate-50 border border-slate-200/80 text-center">
            <div class="text-xs font-black text-slate-800 flex items-center justify-center gap-1.5 mb-1">
              <i class="fa-solid fa-shield-halved text-emerald-600"></i> Cam Kết Hài Lòng 100%
            </div>
            <p class="text-[11px] text-slate-500 font-medium">Hoàn trả học phí trong 7 ngày nếu không đúng cam kết chất lượng.</p>
          </div>

        </div>
      </aside>

    </div>
  </main>

  <!-- ================= FOOTER ================= -->
  <footer class="bg-slate-950 text-slate-400 py-10 text-xs font-semibold border-t border-slate-800 mt-auto">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 flex flex-col sm:flex-row items-center justify-between gap-4">
      <div class="flex items-center gap-2">
        <div class="w-6 h-6 rounded-lg bg-medred-600 text-white flex items-center justify-center text-xs font-black">
          <i class="fa-solid fa-heart-pulse"></i>
        </div>
        <span class="text-white font-black">MedUC MasterClass</span>
        <span>• Khóa Học Ngoại Cơ Sở Thực Chiến</span>
      </div>
      <div class="flex items-center gap-3">
        <a href="/masterclass" class="text-slate-400 hover:text-white transition">Trang Chủ MasterClass</a>
        <span>•</span>
        <a href="/medduo" class="text-slate-400 hover:text-white transition">Luyện Đề MedDuo</a>
      </div>
    </div>
  </footer>

  {literal}
  <script>
    function toggleHeaderSearch() {
      const el = document.getElementById('header-search-bar');
      if (el) el.classList.toggle('hidden');
    }
    function toggleMobileNav() {
      const el = document.getElementById('mobile-nav-drawer');
      if (el) el.classList.toggle('hidden');
    }
  </script>
  {/literal}
</body>
</html>
