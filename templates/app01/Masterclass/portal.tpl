<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Cổng Học Viên Y Khoa MedUC - Tiến Độ & Luyện Thi</title>
  
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
              500: '#f43f5e',
              600: '#e11d48',
              700: '#be123c',
              800: '#9f1239',
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
</head>
<body class="bg-slate-50 text-slate-800 antialiased min-h-screen flex flex-col font-sans">

  <!-- ================= TOP STUDENT HEADER ================= -->
  <header class="sticky top-0 z-50 bg-white border-b border-slate-200/90 shadow-sm">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 h-18 py-3 flex items-center justify-between">
      
      <div class="flex items-center gap-6">
        <a href="/" class="flex items-center group py-1" title="MedUC.vn - Học Y Bứt Phá Cùng Th.S - BSNT">
          <img 
            src="https://cdn.meduc.vn/media/core/logo/logo-meduc.png" 
            alt="MedUC.vn - Học Y Bứt Phá Cùng Th.S - BSNT" 
            class="h-10 sm:h-12 w-auto object-contain transition-transform group-hover:scale-102"
            onerror="this.onerror=null; this.src='/templates/app01/assets/img/logo-w500.png';"
          />
        </a>

        <!-- Desktop Navigation Tabs -->
        <nav class="hidden md:flex items-center gap-6 font-bold text-xs text-slate-600">
          <a href="/portal" class="text-medred-600 border-b-2 border-medred-600 py-4 -mb-3 font-black">Khóa Học Của Tôi</a>
          <a href="/medduo" class="hover:text-medred-600 transition flex items-center gap-1 py-4 -mb-3">
            <i class="fa-solid fa-fire text-orange-500"></i> Luyện Đề MedDuo
          </a>
          <a href="/article-detail" class="hover:text-medred-600 transition flex items-center gap-1 py-4 -mb-3">
            <i class="fa-solid fa-newspaper text-medred-500"></i> Ca Lâm Sàng & ECG
          </a>
          <a href="/masterclass" class="hover:text-medred-600 transition py-4 -mb-3">Khám Phá Thêm</a>
          <a href="/" class="text-slate-400 hover:text-slate-700 transition py-4 -mb-3">Web MedUC Gốc</a>
        </nav>
      </div>

      <!-- Student Stats & Avatar -->
      <div class="flex items-center gap-3 sm:gap-4 font-extrabold text-xs">
        
        <!-- Streak -->
        <div class="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-orange-50 text-orange-600 border border-orange-200/70" title="Chuỗi 7 ngày học liên tiếp">
          <i class="fa-solid fa-fire text-base animate-bounce"></i>
          <span>7 Ngày</span>
        </div>

        <!-- Hearts -->
        <div class="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-duored-50 text-medred-600 border border-medred-200/70" title="Tim làm bài">
          <i class="fa-solid fa-heart text-base text-medred-500"></i>
          <span>5/5</span>
        </div>

        <!-- XP Points -->
        <div class="hidden sm:flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-amber-50 text-amber-600 border border-amber-200/70" title="Điểm kinh nghiệm">
          <i class="fa-solid fa-bolt text-base text-amber-500"></i>
          <span>1.420 XP</span>
        </div>

        <!-- Student Avatar Dropdown -->
        <div class="flex items-center gap-2 pl-3 border-l border-slate-200">
          <img 
            src="https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=200&auto=format&fit=crop&q=80" 
            alt="Avatar Học Viên" 
            class="w-9 h-9 rounded-xl object-cover border-2 border-medred-300"
          />
          <div class="hidden lg:block text-left">
            <div class="text-xs font-black text-slate-900 leading-none">Bảo Nguyễn</div>
            <div class="text-[10px] text-slate-400 font-bold leading-none mt-1">Y5 • HMU</div>
          </div>
        </div>

      </div>

    </div>
  </header>

  <!-- ================= PORTAL CONTENT BODY ================= -->
  <main class="max-w-7xl mx-auto px-4 sm:px-6 py-8 flex-1 w-full space-y-8">
    
    <!-- Welcome Greeting & Daily Challenge Banner -->
    <div class="bg-gradient-to-r from-slate-950 via-slate-900 to-medred-950 text-white rounded-3xl p-6 sm:p-8 shadow-xl relative overflow-hidden flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
      
      <div class="relative z-10 max-w-xl">
        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-medred-600/30 text-medred-300 text-xs font-black uppercase mb-3 border border-medred-500/30">
          <i class="fa-solid fa-bell text-amber-400"></i> THỬ THÁCH HÔM NAY • DAILY CASE
        </span>
        <h1 class="text-2xl sm:text-3xl font-black text-white tracking-tight leading-snug mb-2">
          Chào Bác Sĩ Bảo, Sẵn Sàng Ôn Luyện Hôm Nay?
        </h1>
        <p class="text-xs sm:text-sm text-slate-300 font-medium leading-relaxed">
          Bạn chỉ cần hoàn thành 1 bộ đề trắc nghiệm (5 câu) để duy trì chuỗi học 7 ngày và nhận thêm <strong>+50 XP</strong> thưởng!
        </p>
      </div>

      <div class="relative z-10 shrink-0">
        <a href="/medduo" class="px-6 py-3.5 rounded-2xl bg-medred-600 hover:bg-medred-700 text-white font-black text-xs sm:text-sm shadow-lg shadow-medred-600/30 transition flex items-center gap-2">
          <i class="fa-solid fa-fire text-orange-300"></i>
          <span>LÀM THỬ THÁCH NGAY</span>
        </a>
      </div>

    </div>

    <!-- Section: Continue Watching (Tiếp tục bài giảng) -->
    <div>
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-lg font-black text-slate-900 flex items-center gap-2">
          <i class="fa-solid fa-play text-medred-600 text-sm"></i>
          <span>Tiếp Tục Bài Giảng Đang Học</span>
        </h2>
        <span class="text-xs font-extrabold text-slate-400">Còn 8 bài để hoàn thành</span>
      </div>

      <!-- Active In-progress Card -->
      <div class="bg-white rounded-3xl p-5 border border-slate-200/90 shadow-sm flex flex-col md:flex-row items-center justify-between gap-6 hover:border-medred-200 transition">
        
        <div class="flex items-center gap-4 w-full md:w-auto">
          <div class="relative w-36 aspect-video rounded-2xl overflow-hidden shrink-0 bg-slate-900">
            <img 
              src="https://images.unsplash.com/photo-1551076805-e1869033e561?w=400&auto=format&fit=crop&q=80" 
              alt="Ngoại Cơ Sở" 
              class="w-full h-full object-cover"
            />
            <div class="absolute inset-0 bg-black/40 flex items-center justify-center">
              <i class="fa-solid fa-play text-white text-lg"></i>
            </div>
          </div>
          <div>
            <span class="px-2 py-0.5 rounded-md text-[10px] font-black uppercase bg-medred-50 text-medred-700">Khóa Học Đang Học</span>
            <h3 class="font-black text-slate-900 text-sm sm:text-base mt-1">
              Bài 3: Sờ Bụng: Cảm Ứng Phúc Mạc vs Phản Ứng Thành Bụng
            </h3>
            <p class="text-xs text-slate-400 font-bold mt-0.5">Khóa Ngoại Cơ Sở • TS.BS Nguyễn Văn An</p>
          </div>
        </div>

        <div class="w-full md:w-72 shrink-0 flex items-center gap-4">
          <div class="flex-1">
            <div class="flex justify-between text-[11px] font-bold text-slate-400 mb-1">
              <span>Tiến độ bài</span>
              <span class="text-medred-600 font-black">65%</span>
            </div>
            <div class="w-full bg-slate-100 h-2.5 rounded-full overflow-hidden">
              <div class="bg-medred-600 h-full rounded-full w-[65%]"></div>
            </div>
          </div>
          <button onclick="alert('Đang mở phát video bài 3...')" class="px-4 py-2.5 rounded-xl bg-slate-900 hover:bg-medred-600 text-white font-black text-xs transition shrink-0">
            HỌC TIẾP
          </button>
        </div>

      </div>
    </div>

    <!-- Section: My Enrolled Courses (Khóa học của tôi) -->
    <div>
      <h2 class="text-lg font-black text-slate-900 mb-4 flex items-center gap-2">
        <i class="fa-solid fa-book-open text-medred-600 text-sm"></i>
        <span>Các Khóa Học Đã Đăng Ký (3)</span>
      </h2>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        
        <!-- Course 1 -->
        <div class="bg-white rounded-3xl p-5 border border-slate-200/90 shadow-sm flex flex-col justify-between hover:shadow-md transition">
          <div>
            <div class="aspect-video rounded-2xl overflow-hidden mb-3.5 bg-slate-100">
              <img src="https://images.unsplash.com/photo-1551076805-e1869033e561?w=600&auto=format&fit=crop&q=80" alt="Ngoại Cơ Sở" class="w-full h-full object-cover" />
            </div>
            <span class="text-[10px] font-black uppercase text-medred-600 tracking-wider">Ngoại Khoa</span>
            <h3 class="font-black text-slate-900 text-sm leading-snug mt-1 mb-2">Ngoại Cơ Sở & Khám Bệnh Ngoại Khoa Thực Chiến</h3>
            <div class="flex justify-between text-[11px] font-bold text-slate-400 mb-1">
              <span>Đã hoàn thành 16/24 bài</span>
              <span class="text-emerald-600 font-black">66%</span>
            </div>
            <div class="w-full bg-slate-100 h-2 rounded-full overflow-hidden mb-4">
              <div class="bg-emerald-500 h-full rounded-full w-[66%]"></div>
            </div>
          </div>
          <a href="/course-detail" class="w-full py-2.5 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-800 font-black text-xs text-center transition">
            Vào Lớp Học
          </a>
        </div>

        <!-- Course 2 -->
        <div class="bg-white rounded-3xl p-5 border border-slate-200/90 shadow-sm flex flex-col justify-between hover:shadow-md transition">
          <div>
            <div class="aspect-video rounded-2xl overflow-hidden mb-3.5 bg-slate-100">
              <img src="https://images.unsplash.com/photo-1628348068343-c6a848d2b6dd?w=600&auto=format&fit=crop&q=80" alt="ECG" class="w-full h-full object-cover" />
            </div>
            <span class="text-[10px] font-black uppercase text-medred-600 tracking-wider">Tim Mạch</span>
            <h3 class="font-black text-slate-900 text-sm leading-snug mt-1 mb-2">THE ECG IN PRACTICE & Đọc Nhanh Điện Tâm Đồ</h3>
            <div class="flex justify-between text-[11px] font-bold text-slate-400 mb-1">
              <span>Đã hoàn thành 15/18 bài</span>
              <span class="text-emerald-600 font-black">83%</span>
            </div>
            <div class="w-full bg-slate-100 h-2 rounded-full overflow-hidden mb-4">
              <div class="bg-emerald-500 h-full rounded-full w-[83%]"></div>
            </div>
          </div>
          <button onclick="alert('Đang mở khóa học THE ECG IN PRACTICE...')" class="w-full py-2.5 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-800 font-black text-xs text-center transition">
            Vào Lớp Học
          </button>
        </div>

        <!-- Course 3 -->
        <div class="bg-white rounded-3xl p-5 border border-slate-200/90 shadow-sm flex flex-col justify-between hover:shadow-md transition">
          <div>
            <div class="aspect-video rounded-2xl overflow-hidden mb-3.5 bg-slate-100">
              <img src="https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=600&auto=format&fit=crop&q=80" alt="Tiền Lâm Sàng" class="w-full h-full object-cover" />
            </div>
            <span class="text-[10px] font-black uppercase text-medred-600 tracking-wider">Tiền Lâm Sàng</span>
            <h3 class="font-black text-slate-900 text-sm leading-snug mt-1 mb-2">Tiền Lâm Sàng Toàn Diện [Kỹ Năng Tiếp Cận Người Bệnh]</h3>
            <div class="flex justify-between text-[11px] font-bold text-slate-400 mb-1">
              <span>Đã hoàn thành 6/32 bài</span>
              <span class="text-amber-600 font-black">18%</span>
            </div>
            <div class="w-full bg-slate-100 h-2 rounded-full overflow-hidden mb-4">
              <div class="bg-amber-500 h-full rounded-full w-[18%]"></div>
            </div>
          </div>
          <button onclick="alert('Đang mở khóa học Tiền Lâm Sàng...')" class="w-full py-2.5 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-800 font-black text-xs text-center transition">
            Vào Lớp Học
          </button>
        </div>

      </div>
    </div>

  </main>

  <!-- Footer -->
  <footer class="bg-white border-t border-slate-200/80 py-6 text-center text-xs font-bold text-slate-400 mt-auto">
    <div class="max-w-7xl mx-auto px-4 flex flex-col sm:flex-row items-center justify-between gap-3">
      <span>© 2026 MedUC Academy • Cổng học tập dành riêng cho sinh viên Y</span>
      <div class="flex items-center gap-4">
        <a href="/masterclass" class="hover:text-medred-600">Trang Chủ MasterClass</a>
        <span>•</span>
        <a href="/medduo" class="hover:text-medred-600">Luyện Đề MedDuo</a>
      </div>
    </div>
  </footer>

</body>
</html>
