<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>MedDuo - Luyện Đề Y Khoa Duolingo | MedUC</title>
  
  <!-- Tailwind CSS CDN -->
  <script src="https://cdn.tailwindcss.com"></script>
  {literal}
  <script>
    tailwind.config = {
      theme: {
        extend: {
          colors: {
            duored: {
              50: '#fff1f2',
              100: '#ffe4e6',
              200: '#fecdd3',
              400: '#fb7185',
              500: '#f43f5e',
              600: '#e11d48',
              700: '#be123c',
              800: '#9f1239',
              900: '#881337',
            }
          },
          fontFamily: {
            nunito: ['"Nunito"', 'system-ui', '-apple-system', 'sans-serif'],
          }
        }
      }
    }
  </script>
  {/literal}

  <!-- Google Fonts (Nunito) & Font Awesome 6 -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

  {literal}
  <style>
    body {
      font-family: 'Nunito', sans-serif;
      background-color: #f8fafc;
    }

    /* Duolingo style 3D buttons */
    .btn-3d-red {
      background-color: #e11d48;
      box-shadow: 0 4px 0 #be123c;
      transition: all 0.1s ease;
    }
    .btn-3d-red:hover {
      background-color: #f43f5e;
      box-shadow: 0 4px 0 #be123c;
    }
    .btn-3d-red:active {
      transform: translateY(3px);
      box-shadow: 0 1px 0 #be123c;
    }

    .btn-3d-white {
      background-color: #ffffff;
      box-shadow: 0 3px 0 #e2e8f0;
      border: 2px solid #e2e8f0;
      transition: all 0.1s ease;
    }
    .btn-3d-white:hover {
      border-color: #cbd5e1;
      background-color: #f8fafc;
    }
    .btn-3d-white:active {
      transform: translateY(2px);
      box-shadow: 0 1px 0 #cbd5e1;
    }

    .btn-3d-active {
      background-color: #fff1f2 !important;
      border-color: #e11d48 !important;
      color: #e11d48 !important;
      box-shadow: 0 3px 0 #be123c !important;
    }

    /* Custom card border style */
    .duo-card {
      border: 2px solid #e2e8f0;
      border-bottom: 4px solid #cbd5e1;
      transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
    }
    .duo-card:hover {
      border-color: #fecdd3;
      border-bottom-color: #e11d48;
      transform: translateY(-2px);
      box-shadow: 0 12px 20px -8px rgba(225, 29, 72, 0.12);
    }

    /* Sidebar custom scrollbar */
    .sidebar-scroll::-webkit-scrollbar {
      width: 5px;
    }
    .sidebar-scroll::-webkit-scrollbar-track {
      background: transparent;
    }
    .sidebar-scroll::-webkit-scrollbar-thumb {
      background: #fecdd3;
      border-radius: 9999px;
    }

    /* Option button in quiz */
    .quiz-option {
      border: 2px solid #e2e8f0;
      border-bottom: 4px solid #cbd5e1;
      transition: all 0.15s ease;
      cursor: pointer;
    }
    .quiz-option:hover {
      background-color: #fff1f2;
      border-color: #fecdd3;
    }
    .quiz-option.selected {
      border-color: #e11d48;
      border-bottom-color: #be123c;
      background-color: #fff1f2;
      color: #9f1239;
    }
    .quiz-option.correct {
      border-color: #10b981 !important;
      border-bottom-color: #047857 !important;
      background-color: #ecfdf5 !important;
      color: #065f46 !important;
    }
    .quiz-option.incorrect {
      border-color: #ef4444 !important;
      border-bottom-color: #b91c1c !important;
      background-color: #fef2f2 !important;
      color: #991b1b !important;
    }

    /* Pulse animation for current active card */
    @keyframes pulse-subtle {
      0%, 100% { opacity: 1; }
      50% { opacity: 0.85; }
    }
    .pulse-glow {
      animation: pulse-subtle 2s infinite ease-in-out;
    }
  </style>
  {/literal}
</head>
<body class="text-slate-800 antialiased min-h-screen flex flex-col selection:bg-duored-100 selection:text-duored-700">

  <!-- ================= TOP NAVIGATION BAR ================= -->
  <header class="sticky top-0 z-40 bg-white border-b-2 border-slate-100 shadow-sm">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 h-18 py-3 flex items-center justify-between">
      
      <!-- MedUC Official Brand Logo + MedDuo -->
      <div class="flex items-center gap-3 cursor-pointer py-1" onclick="resetAllFilters()">
        <a href="/" title="MedUC.vn - Học Y Bứt Phá Cùng Th.S - BSNT">
          <img 
            src="https://cdn.meduc.vn/media/core/logo/logo-meduc.png" 
            alt="MedUC.vn - Học Y Bứt Phá Cùng Th.S - BSNT" 
            class="h-10 sm:h-12 w-auto object-contain transition-transform hover:scale-102"
            onerror="this.onerror=null; this.src='/templates/app01/assets/img/logo-w500.png';"
          />
        </a>
        <div class="hidden sm:flex items-center gap-2 pl-3 border-l border-slate-200">
          <span class="px-2 py-0.5 rounded-md text-[11px] font-black bg-orange-100 text-orange-700 uppercase tracking-wide flex items-center gap-1">
            <i class="fa-solid fa-fire text-orange-500"></i> MedDuo
          </span>
          <span class="text-xs font-bold text-slate-400 hidden md:inline">713 Bộ Đề Y Khoa</span>
        </div>
      </div>

      <!-- Gamified Student Counters -->
      <div class="flex items-center gap-2 sm:gap-4 font-extrabold text-xs sm:text-sm">
        
        <!-- Streak -->
        <div class="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-orange-50 text-orange-600 border border-orange-200/70" title="Chuỗi ngày ôn thi liên tiếp">
          <i class="fa-solid fa-fire text-base text-orange-500 animate-bounce"></i>
          <span id="streak-counter">7 Ngày</span>
        </div>

        <!-- Hearts -->
        <div class="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-duored-50 text-duored-600 border border-duored-200/70" title="Tim còn lại">
          <i class="fa-solid fa-heart text-base text-duored-500"></i>
          <span id="heart-counter">5/5</span>
        </div>

        <!-- XP Points -->
        <div class="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-amber-50 text-amber-600 border border-amber-200/70" title="Điểm kinh nghiệm tích lũy">
          <i class="fa-solid fa-bolt text-base text-amber-500"></i>
          <span id="user-xp">360 XP</span>
        </div>

        <!-- Return to MedUC -->
        <div class="hidden sm:flex items-center gap-1 border-l pl-3 border-slate-200">
          <a href="/" class="px-3 py-1.5 rounded-xl text-xs font-black text-slate-600 hover:text-duored-600 hover:bg-slate-50 transition border border-slate-200">
            <i class="fa-solid fa-house mr-1"></i> Trang Chủ MedUC
          </a>
        </div>

      </div>

    </div>
  </header>

  <!-- ================= 2-COLUMN MAIN LAYOUT ================= -->
  <div class="max-w-7xl mx-auto px-4 sm:px-6 py-6 flex-1 w-full">
    <div class="flex flex-col md:flex-row gap-6 items-start">
      
      <!-- ================= LEFT COLUMN: HIERARCHICAL FILTERS SIDEBAR ================= -->
      <aside class="w-full md:w-80 lg:w-84 shrink-0 md:sticky md:top-20 self-start">
        <div class="bg-white rounded-3xl p-5 border-2 border-slate-200/90 shadow-sm space-y-5 max-h-[calc(100vh-6.5rem)] overflow-y-auto sidebar-scroll">
          
          <!-- Sidebar Header & Reset -->
          <div class="flex items-center justify-between pb-3 border-b border-slate-100">
            <div class="flex items-center gap-2">
              <span class="w-7 h-7 rounded-xl bg-duored-100 text-duored-700 flex items-center justify-center text-xs font-black">
                <i class="fa-solid fa-sliders"></i>
              </span>
              <h2 class="text-base font-black text-slate-900">Bộ Lọc Chuyên Khoa</h2>
            </div>
            <button 
              onclick="resetAllFilters()" 
              class="text-xs font-extrabold text-slate-400 hover:text-duored-600 transition flex items-center gap-1">
              <i class="fa-solid fa-rotate-left text-[11px]"></i>
              <span>Đặt lại</span>
            </button>
          </div>

          <!-- Quick Search Inside Sidebar -->
          <div>
            <label for="sidebar-search" class="block text-xs font-black uppercase tracking-wider text-slate-400 mb-1.5">
              🔍 Tìm nhanh đề thi
            </label>
            <div class="relative">
              <input 
                type="text" 
                id="sidebar-search"
                oninput="handleSidebarSearch()"
                placeholder="Tìm ECG, Hen, Dược lý, Giải phẫu..."
                class="w-full pl-9 pr-8 py-2.5 rounded-2xl bg-slate-100 focus:bg-white text-slate-800 text-xs font-bold border-2 border-slate-200 focus:border-duored-500 focus:outline-none transition"
              />
              <div class="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-xs">
                <i class="fa-solid fa-magnifying-glass"></i>
              </div>
              <button 
                id="sidebar-clear-search" 
                onclick="clearSidebarSearch()" 
                class="hidden absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 text-xs">
                <i class="fa-solid fa-circle-xmark"></i>
              </button>
            </div>
          </div>

          <!-- CẤP 1: CHUYÊN KHOA Y HỌC (Categories thật từ Database) -->
          <div>
            <div class="flex items-center justify-between mb-2">
              <span class="text-xs font-black uppercase tracking-wider text-slate-400 flex items-center gap-1.5">
                <i class="fa-solid fa-book-medical text-duored-500"></i> Chuyên Khoa / Bộ Môn
              </span>
              <span id="badge-category-count" class="text-[10px] font-black text-slate-400">Tất cả</span>
            </div>

            <!-- Categories pills container -->
            <div class="flex flex-col gap-1.5 max-h-60 overflow-y-auto sidebar-scroll pr-1" id="category-filter-group">
              <button 
                onclick="selectCategory(0)" 
                data-category="0" 
                class="category-btn w-full text-left px-3 py-2 rounded-xl text-xs font-black btn-3d-white btn-3d-active flex items-center justify-between">
                <span><i class="fa-solid fa-layer-group text-duored-500 mr-1.5"></i> Tất cả chuyên khoa</span>
                <span class="text-[10px] px-2 py-0.5 rounded-full bg-slate-100 text-slate-600" id="total-quizzes-badge">713</span>
              </button>

              {if !empty($categories)}
                {foreach from=$categories item=cat}
                  <button 
                    onclick="selectCategory({$cat.id})" 
                    data-category="{$cat.id}" 
                    class="category-btn w-full text-left px-3 py-2 rounded-xl text-xs font-black btn-3d-white flex items-center justify-between">
                    <span class="truncate pr-2"><i class="fa-solid fa-stethoscope text-slate-400 mr-1.5"></i> {$cat.name|escape}</span>
                    <span class="text-[10px] px-2 py-0.5 rounded-full bg-slate-100 text-slate-600 shrink-0">{$cat.total_quiz}</span>
                  </button>
                {/foreach}
              {/if}
            </div>
          </div>

          <!-- CẤP 2: HỆ ĐÀO TẠO & KỲ THI -->
          <div>
            <span class="text-xs font-black uppercase tracking-wider text-slate-400 flex items-center gap-1.5 mb-2">
              <i class="fa-solid fa-graduation-cap text-duored-500"></i> Đối Tượng Ôn Thi
            </span>
            <div class="grid grid-cols-2 gap-1.5">
              <button 
                onclick="selectExamType('all')" 
                data-type="all"
                class="type-btn px-2.5 py-1.5 rounded-xl text-xs font-black btn-3d-white btn-3d-active">
                🎯 Toàn bộ
              </button>
              <button 
                onclick="selectExamType('noitru')" 
                data-type="noitru"
                class="type-btn px-2.5 py-1.5 rounded-xl text-xs font-black btn-3d-white">
                🏥 Bác Sĩ Nội Trú
              </button>
              <button 
                onclick="selectExamType('dakhoa')" 
                data-type="dakhoa"
                class="type-btn px-2.5 py-1.5 rounded-xl text-xs font-black btn-3d-white">
                🩺 Y Đa Khoa
              </button>
              <button 
                onclick="selectExamType('chuyenkhoa')" 
                data-type="chuyenkhoa"
                class="type-btn px-2.5 py-1.5 rounded-xl text-xs font-black btn-3d-white">
                📚 Chuyên Khoa 1
              </button>
            </div>
          </div>

          <!-- CẤP 3: TRƯỜNG ĐẠI HỌC Y (Mô phỏng trường Y) -->
          <div>
            <span class="text-xs font-black uppercase tracking-wider text-slate-400 flex items-center gap-1.5 mb-2">
              <i class="fa-solid fa-building-columns text-duored-500"></i> Cơ Sở Đào Tạo
            </span>
            <div class="grid grid-cols-2 gap-1.5">
              <button onclick="selectSchool('all')" data-school="all" class="school-btn px-2 py-1.5 rounded-xl text-xs font-black btn-3d-white btn-3d-active">Tất cả trường</button>
              <button onclick="selectSchool('HMU')" data-school="HMU" class="school-btn px-2 py-1.5 rounded-xl text-xs font-black btn-3d-white">ĐH Y Hà Nội</button>
              <button onclick="selectSchool('UMP')" data-school="UMP" class="school-btn px-2 py-1.5 rounded-xl text-xs font-black btn-3d-white">ĐH Y Dược TPHCM</button>
              <button onclick="selectSchool('Hue')" data-school="Hue" class="school-btn px-2 py-1.5 rounded-xl text-xs font-black btn-3d-white">Y Dược Huế</button>
            </div>
          </div>

        </div>
      </aside>

      <!-- ================= RIGHT COLUMN: QUIZ CARDS GRID ================= -->
      <main class="flex-1 min-w-0 w-full">
        
        <!-- Header bar of Right Column -->
        <div class="bg-white rounded-3xl p-4 sm:p-5 border-2 border-slate-200/90 shadow-sm mb-6 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
          <div>
            <div class="flex items-center gap-2">
              <span class="w-3 h-3 rounded-full bg-duored-600"></span>
              <h2 class="text-lg sm:text-xl font-black text-slate-900">Thư Viện Bộ Đề Y Khoa</h2>
              <span id="results-pill" class="px-2.5 py-0.5 rounded-full text-xs font-black bg-duored-100 text-duored-700">
                {count($quizzes)} bộ đề
              </span>
            </div>
            <div id="active-filter-breadcrumbs" class="text-xs text-slate-400 font-semibold mt-1 flex flex-wrap items-center gap-1.5">
              <span>Đang hiển thị: Toàn bộ đề thi thật MedUC</span>
            </div>
          </div>

          <!-- Sort Selector -->
          <div class="flex items-center gap-2 shrink-0 self-end sm:self-center">
            <span class="text-xs font-extrabold text-slate-400"><i class="fa-solid fa-arrow-down-wide-short mr-1"></i>Sắp xếp:</span>
            <select 
              id="sort-select" 
              onchange="handleSortChange()"
              class="bg-slate-100 text-slate-700 text-xs font-bold rounded-xl px-3 py-2 border-2 border-slate-200 focus:outline-none focus:border-duored-500">
              <option value="newest">Bộ đề mới nhất</option>
              <option value="popular">Lượt thi nhiều nhất</option>
              <option value="time_asc">Thời gian ngắn nhất</option>
              <option value="questions_desc">Nhiều câu hỏi nhất</option>
            </select>
          </div>
        </div>

        <!-- Cards Grid Container -->
        <div id="cards-container" class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-5">
          <!-- Populated by JavaScript from initial JSON data -->
        </div>

        <!-- Empty State -->
        <div id="empty-view" class="hidden text-center py-16 bg-white rounded-3xl border-2 border-dashed border-slate-200 p-6">
          <div class="text-5xl mb-3">🧐</div>
          <h3 class="text-base font-black text-slate-800">Không tìm thấy bộ đề phù hợp</h3>
          <p class="text-xs text-slate-500 font-semibold mt-1 mb-4">
            Hãy thử bấm "Đặt lại" bên cột trái hoặc đổi từ khóa tìm kiếm bạn nhé!
          </p>
          <button onclick="resetAllFilters()" class="px-5 py-2.5 rounded-xl text-xs font-black text-white btn-3d-red">
            Xem tất cả bộ đề
          </button>
        </div>

      </main>

    </div>
  </div>

  <!-- ================= FOOTER ================= -->
  <footer class="bg-white border-t-2 border-slate-100 py-6 text-center text-xs font-bold text-slate-400 mt-auto">
    <div class="max-w-7xl mx-auto px-4 flex flex-col sm:flex-row items-center justify-between gap-3">
      <div class="flex items-center gap-2">
        <div class="w-6 h-6 rounded-lg bg-duored-600 flex items-center justify-center text-white text-xs font-black">
          <i class="fa-solid fa-heart-pulse"></i>
        </div>
        <span class="text-slate-700 font-black">MedDuo Duolingo Engine</span>
        <span>• Trực quan • Dữ liệu thật từ MedUC</span>
      </div>
      <div class="flex items-center gap-3">
        <a href="/" class="text-slate-500 hover:text-duored-600 font-bold">Trang Chủ</a>
        <span>•</span>
        <a href="/khoa-hoc" class="text-slate-500 hover:text-duored-600 font-bold">Khóa Học & Sách</a>
        <span>•</span>
        <a href="/admin" class="text-duored-600 hover:underline font-black">Admin Panel ➔</a>
      </div>
    </div>
  </footer>

  <!-- ================= DUOLINGO STYLE QUIZ PLAYER MODAL ================= -->
  <div id="duo-quiz-modal" class="fixed inset-0 z-50 hidden flex flex-col bg-white">
    
    <!-- Top Quiz Header -->
    <div class="max-w-3xl mx-auto w-full px-4 pt-4 pb-3 flex items-center gap-4 border-b border-slate-100">
      <button onclick="closeDuoModal()" class="text-slate-400 hover:text-slate-600 text-xl font-black p-2 transition" title="Thoát bài luyện">
        <i class="fa-solid fa-xmark"></i>
      </button>

      <!-- Progress Bar -->
      <div class="flex-1 bg-slate-100 h-3.5 rounded-full overflow-hidden p-0.5">
        <div id="quiz-progress-bar" class="bg-duored-500 h-full rounded-full transition-all duration-300 w-0"></div>
      </div>

      <!-- Question Counter & Hearts -->
      <div class="flex items-center gap-3">
        <span id="quiz-step-counter" class="text-xs font-black text-slate-400">Câu 1/10</span>
        <div class="flex items-center gap-1 text-duored-600 font-black text-sm">
          <i class="fa-solid fa-heart text-base"></i>
          <span id="quiz-hearts">5</span>
        </div>
      </div>
    </div>

    <!-- Quiz Content Body -->
    <div class="max-w-2xl mx-auto w-full px-4 py-6 flex-1 overflow-y-auto flex flex-col justify-center">
      
      <!-- Question meta & title -->
      <div class="mb-4">
        <div class="flex items-center gap-2 mb-1.5">
          <span id="modal-tag" class="px-2.5 py-1 rounded-lg text-xs font-extrabold bg-duored-50 text-duored-700 border border-duored-100">
            Chuyên Khoa
          </span>
          <span id="modal-quiz-title" class="text-xs font-bold text-slate-400 truncate max-w-md"></span>
        </div>
        
        <h3 class="text-lg sm:text-xl font-black text-slate-900 leading-snug" id="modal-question-text">
          Đang nạp câu hỏi trắc nghiệm...
        </h3>

        <div id="modal-question-desc" class="hidden text-xs text-slate-600 mt-2 p-3 bg-slate-50 rounded-xl border border-slate-100 leading-relaxed">
          <!-- Optional case description -->
        </div>

        <div id="modal-question-image" class="hidden mt-3 text-center">
          <img src="" alt="Hình ảnh câu hỏi" class="max-h-60 rounded-xl mx-auto border border-slate-200" />
        </div>
      </div>

      <!-- Options Container -->
      <div class="space-y-3 mt-3" id="modal-options-list">
        <!-- Injected options -->
      </div>

    </div>

    <!-- Bottom Action Drawer (Duolingo Style!) -->
    <div id="bottom-drawer" class="border-t-2 border-slate-100 p-4 sm:py-5 bg-white transition-all">
      <div class="max-w-2xl mx-auto flex items-center justify-between gap-4">
        
        <div id="drawer-feedback" class="hidden flex items-center gap-3">
          <div id="drawer-icon" class="w-10 h-10 rounded-2xl flex items-center justify-center text-xl font-black shrink-0"></div>
          <div>
            <h4 id="drawer-title" class="font-black text-sm sm:text-base"></h4>
            <div id="drawer-desc" class="text-xs sm:text-sm font-semibold text-slate-600 max-w-md line-clamp-3 leading-snug"></div>
          </div>
        </div>

        <button 
          id="btn-quiz-action"
          onclick="handleQuizAction()"
          class="ml-auto px-8 py-3 rounded-2xl text-white font-black text-sm sm:text-base btn-3d-red">
          KIỂM TRA
        </button>

      </div>
    </div>

  </div>

  <!-- ================= SUMMARY RESULT MODAL ================= -->
  <div id="quiz-summary-modal" class="fixed inset-0 z-50 hidden flex items-center justify-center bg-slate-900/60 backdrop-blur-sm p-4">
    <div class="bg-white rounded-3xl p-6 sm:p-8 max-w-md w-full text-center border-4 border-slate-100 shadow-2xl transform transition-all">
      <div class="text-6xl mb-3 animate-bounce">🏆</div>
      <h3 class="text-2xl font-black text-slate-900">Hoàn Thành Bài Luyện!</h3>
      <p class="text-xs text-slate-400 font-bold mt-1 mb-6">Bạn vừa hoàn thành xuất sắc một bộ đề Y khoa</p>

      <div class="grid grid-cols-3 gap-3 mb-6">
        <div class="bg-emerald-50 border border-emerald-100 rounded-2xl p-3">
          <div class="text-emerald-600 font-black text-xl" id="summary-correct">0</div>
          <div class="text-[11px] font-bold text-emerald-700 mt-0.5">Đúng</div>
        </div>
        <div class="bg-rose-50 border border-rose-100 rounded-2xl p-3">
          <div class="text-rose-600 font-black text-xl" id="summary-wrong">0</div>
          <div class="text-[11px] font-bold text-rose-700 mt-0.5">Chưa đúng</div>
        </div>
        <div class="bg-amber-50 border border-amber-100 rounded-2xl p-3">
          <div class="text-amber-600 font-black text-xl" id="summary-xp">+0</div>
          <div class="text-[11px] font-bold text-amber-700 mt-0.5">XP Đạt Được</div>
        </div>
      </div>

      <div class="space-y-2.5">
        <button onclick="restartCurrentQuiz()" class="w-full py-3 rounded-2xl text-white font-black text-sm btn-3d-red">
          <i class="fa-solid fa-rotate-right mr-1.5"></i> Luyện Lại Bộ Đề Này
        </button>
        <button onclick="closeSummaryModal()" class="w-full py-3 rounded-2xl text-slate-600 font-black text-sm btn-3d-white">
          Quay Về Danh Sách Đề
        </button>
      </div>
    </div>
  </div>

  <!-- Raw initial data passed from CakePHP Controller -->
  <script>
    const INITIAL_QUIZZES = {$quizzes_json};
    const INITIAL_CATEGORIES = {$categories_json};
  </script>

  <!-- ================= CLIENT JAVASCRIPT ENGINE ================= -->
  {literal}
  <script>
    // State
    let allQuizzes = INITIAL_QUIZZES || [];
    let currentFilters = {
      categoryId: 0,
      examType: 'all',
      school: 'all',
      keyword: '',
      sort: 'newest'
    };

    let userXP = 360;
    let userHearts = 5;

    // Active Running Quiz State
    let currentQuizDetail = null;
    let currentQuestionIndex = 0;
    let userSelectedOption = null;
    let isQuestionChecked = false;
    let quizUserAnswers = {};
    let correctCount = 0;
    let wrongCount = 0;

    // Initialize on load
    window.addEventListener('DOMContentLoaded', () => {
      renderCards();
    });

    // Filter by Category
    function selectCategory(catId) {
      currentFilters.categoryId = parseInt(catId);
      document.querySelectorAll('.category-btn').forEach(btn => {
        if (parseInt(btn.getAttribute('data-category')) === parseInt(catId)) {
          btn.classList.add('btn-3d-active');
        } else {
          btn.classList.remove('btn-3d-active');
        }
      });
      renderCards();
    }

    // Filter by Exam Type
    function selectExamType(type) {
      currentFilters.examType = type;
      document.querySelectorAll('.type-btn').forEach(btn => {
        if (btn.getAttribute('data-type') === type) {
          btn.classList.add('btn-3d-active');
        } else {
          btn.classList.remove('btn-3d-active');
        }
      });
      renderCards();
    }

    // Filter by School
    function selectSchool(school) {
      currentFilters.school = school;
      document.querySelectorAll('.school-btn').forEach(btn => {
        if (btn.getAttribute('data-school') === school) {
          btn.classList.add('btn-3d-active');
        } else {
          btn.classList.remove('btn-3d-active');
        }
      });
      renderCards();
    }

    // Search Keyword
    function handleSidebarSearch() {
      const q = document.getElementById('sidebar-search').value.trim();
      currentFilters.keyword = q;
      const clearBtn = document.getElementById('sidebar-clear-search');
      if (q.length > 0) {
        clearBtn.classList.remove('hidden');
      } else {
        clearBtn.classList.add('hidden');
      }
      renderCards();
    }

    function clearSidebarSearch() {
      document.getElementById('sidebar-search').value = '';
      currentFilters.keyword = '';
      document.getElementById('sidebar-clear-search').classList.add('hidden');
      renderCards();
    }

    // Sort Change
    function handleSortChange() {
      currentFilters.sort = document.getElementById('sort-select').value;
      renderCards();
    }

    // Reset All Filters
    function resetAllFilters() {
      currentFilters = {
        categoryId: 0,
        examType: 'all',
        school: 'all',
        keyword: '',
        sort: 'newest'
      };
      document.getElementById('sidebar-search').value = '';
      document.getElementById('sidebar-clear-search').classList.add('hidden');
      document.getElementById('sort-select').value = 'newest';

      selectCategory(0);
      selectExamType('all');
      selectSchool('all');
    }

    // Render Cards in Right Column
    function renderCards() {
      const container = document.getElementById('cards-container');
      const emptyView = document.getElementById('empty-view');
      const resultsPill = document.getElementById('results-pill');
      const breadcrumbs = document.getElementById('active-filter-breadcrumbs');

      // Filter locally
      let filtered = allQuizzes.filter(q => {
        if (currentFilters.categoryId > 0 && q.category_id !== currentFilters.categoryId) {
          return false;
        }

        if (currentFilters.keyword) {
          const kw = currentFilters.keyword.toLowerCase();
          const matchTitle = q.title.toLowerCase().includes(kw);
          const matchCat = q.category_name.toLowerCase().includes(kw);
          if (!matchTitle && !matchCat) return false;
        }

        return true;
      });

      // Sort
      if (currentFilters.sort === 'newest') {
        filtered.sort((a, b) => b.id - a.id);
      } else if (currentFilters.sort === 'popular') {
        filtered.sort((a, b) => b.attempts - a.attempts);
      } else if (currentFilters.sort === 'time_asc') {
        filtered.sort((a, b) => a.time_min - b.time_min);
      } else if (currentFilters.sort === 'questions_desc') {
        filtered.sort((a, b) => b.questions_count - a.questions_count);
      }

      // Update pill and breadcrumbs
      resultsPill.textContent = `${filtered.length} bộ đề`;

      const crumbs = [];
      if (currentFilters.categoryId > 0) {
        const activeCat = INITIAL_CATEGORIES.find(c => parseInt(c.id) === currentFilters.categoryId);
        crumbs.push(`Chuyên khoa: <strong class="text-duored-600">${activeCat ? activeCat.name : ''}</strong>`);
      }
      if (currentFilters.keyword) {
        crumbs.push(`Từ khóa: "<strong class="text-slate-800">${currentFilters.keyword}</strong>"`);
      }
      if (crumbs.length === 0) {
        breadcrumbs.innerHTML = `<span>Đang hiển thị: Toàn bộ đề thi thật MedUC</span>`;
      } else {
        breadcrumbs.innerHTML = `<span>Đang lọc: ${crumbs.join(' • ')}</span>`;
      }

      if (filtered.length === 0) {
        container.innerHTML = '';
        emptyView.classList.remove('hidden');
        return;
      }

      emptyView.classList.add('hidden');

      // Colors palette for cards
      const categoryColors = [
        { bg: 'bg-rose-50', text: 'text-rose-600', icon: 'fa-heart-pulse' },
        { bg: 'bg-blue-50', text: 'text-blue-600', icon: 'fa-brain' },
        { bg: 'bg-emerald-50', text: 'text-emerald-600', icon: 'fa-lungs' },
        { bg: 'bg-amber-50', text: 'text-amber-600', icon: 'fa-pills' },
        { bg: 'bg-indigo-50', text: 'text-indigo-600', icon: 'fa-bone' },
        { bg: 'bg-purple-50', text: 'text-purple-600', icon: 'fa-dna' }
      ];

      container.innerHTML = filtered.map((item, idx) => {
        const theme = categoryColors[idx % categoryColors.length];
        return `
          <article class="bg-white rounded-3xl p-5 duo-card flex flex-col justify-between group">
            <div>
              <!-- Top Banner & Category Badge -->
              <div class="flex items-center justify-between mb-3">
                <span class="px-2.5 py-1 rounded-xl text-xs font-black ${theme.bg} ${theme.text} flex items-center gap-1.5 border border-slate-100">
                  <i class="fa-solid ${theme.icon}"></i>
                  <span>${item.category_name}</span>
                </span>
                <span class="text-[11px] font-black text-slate-400">#${item.id}</span>
              </div>

              <!-- Title -->
              <h3 class="font-black text-slate-900 text-base leading-snug group-hover:text-duored-600 transition line-clamp-2">
                ${item.title}
              </h3>
            </div>

            <!-- Bottom Stats & Start Button -->
            <div class="mt-4 pt-3 border-t border-slate-100">
              <div class="flex items-center justify-between text-xs font-extrabold text-slate-400 mb-3">
                <span class="flex items-center gap-1"><i class="fa-regular fa-clock text-duored-500"></i> ${item.time_min} phút</span>
                <span class="flex items-center gap-1"><i class="fa-solid fa-list-check text-duored-500"></i> ${item.questions_count} câu</span>
                <span class="flex items-center gap-1 text-amber-500"><i class="fa-solid fa-star"></i> ${item.rating}</span>
              </div>

              <button 
                onclick="startQuiz(${item.id})"
                class="w-full py-2.5 rounded-2xl text-white font-black text-xs sm:text-sm btn-3d-red flex items-center justify-center gap-2">
                <i class="fa-solid fa-play text-xs"></i>
                <span>LUYỆN TẬP NGAY</span>
              </button>
            </div>
          </article>
        `;
      }).join('');
    }

    // ================= QUIZ MODAL ENGINE =================
    async function startQuiz(quizId) {
      try {
        // Show loading state or fetch API
        const btn = event ? event.currentTarget : null;
        if (btn) btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> <span>Đang nạp đề...</span>';

        const res = await fetch(`/medduo/api/quiz/${quizId}`);
        const json = await res.json();

        if (btn) btn.innerHTML = '<i class="fa-solid fa-play text-xs"></i> <span>LUYỆN TẬP NGAY</span>';

        if (json.status !== 200 || !json.data || !json.data.questions || json.data.questions.length === 0) {
          alert('Không thể tải câu hỏi của bộ đề này. Vui lòng thử bộ đề khác!');
          return;
        }

        currentQuizDetail = json.data;
        currentQuestionIndex = 0;
        quizUserAnswers = {};
        correctCount = 0;
        wrongCount = 0;

        document.getElementById('modal-tag').textContent = currentQuizDetail.category_name;
        document.getElementById('modal-quiz-title').textContent = currentQuizDetail.title;

        loadQuestion(currentQuestionIndex);
        document.getElementById('duo-quiz-modal').classList.remove('hidden');
        document.body.style.overflow = 'hidden';

      } catch (err) {
        alert('Lỗi kết nối khi tải đề thi. Vui lòng thử lại!');
      }
    }

    function loadQuestion(index) {
      if (!currentQuizDetail || !currentQuizDetail.questions[index]) return;

      const q = currentQuizDetail.questions[index];
      userSelectedOption = null;
      isQuestionChecked = false;

      // Update progress bar
      const progressPercent = Math.round(((index + 1) / currentQuizDetail.questions.length) * 100);
      document.getElementById('quiz-progress-bar').style.width = `${progressPercent}%`;
      document.getElementById('quiz-step-counter').textContent = `Câu ${index + 1} / ${currentQuizDetail.questions.length}`;

      // Render Question Title
      document.getElementById('modal-question-text').textContent = q.question;

      // Optional vignette description
      const descEl = document.getElementById('modal-question-desc');
      if (q.description && q.description.trim() !== '') {
        descEl.innerHTML = q.description;
        descEl.classList.remove('hidden');
      } else {
        descEl.classList.add('hidden');
      }

      // Optional image
      const imgContainer = document.getElementById('modal-question-image');
      if (q.image && q.image.trim() !== '') {
        imgContainer.querySelector('img').src = q.image;
        imgContainer.classList.remove('hidden');
      } else {
        imgContainer.classList.add('hidden');
      }

      // Render Options
      const optionsContainer = document.getElementById('modal-options-list');
      optionsContainer.innerHTML = q.options.map((opt, idx) => `
        <button 
          onclick="selectOption(${idx})" 
          id="quiz-opt-${idx}" 
          class="quiz-option w-full text-left p-3.5 sm:p-4 rounded-2xl font-bold text-sm sm:text-base text-slate-700 flex items-center gap-3">
          <span class="w-8 h-8 rounded-xl bg-slate-100 font-black text-xs flex items-center justify-center text-slate-500 shrink-0 option-badge">
            ${String.fromCharCode(65 + idx)}
          </span>
          <span class="flex-1 leading-snug">${opt}</span>
        </button>
      `).join('');

      resetBottomDrawer();
    }

    function selectOption(idx) {
      if (isQuestionChecked) return;
      userSelectedOption = idx;

      const totalOptions = currentQuizDetail.questions[currentQuestionIndex].options.length;
      for (let i = 0; i < totalOptions; i++) {
        const btn = document.getElementById(`quiz-opt-${i}`);
        if (btn) {
          if (i === idx) {
            btn.classList.add('selected');
          } else {
            btn.classList.remove('selected');
          }
        }
      }
    }

    function resetBottomDrawer() {
      const drawer = document.getElementById('bottom-drawer');
      const feedback = document.getElementById('drawer-feedback');
      const actionBtn = document.getElementById('btn-quiz-action');

      drawer.className = 'border-t-2 border-slate-100 p-4 sm:py-5 bg-white transition-all';
      feedback.classList.add('hidden');
      actionBtn.textContent = 'KIỂM TRA';
      actionBtn.className = 'ml-auto px-8 py-3 rounded-2xl text-white font-black text-sm sm:text-base btn-3d-red';
    }

    function handleQuizAction() {
      const currentQ = currentQuizDetail.questions[currentQuestionIndex];
      const isLastQuestion = (currentQuestionIndex + 1) >= currentQuizDetail.questions.length;

      if (!isQuestionChecked) {
        // Step 1: Validate option selection
        if (userSelectedOption === null) {
          alert('Vui lòng chọn 1 đáp án A, B, C hoặc D trước bạn nhé! 😊');
          return;
        }

        isQuestionChecked = true;
        quizUserAnswers[currentQuestionIndex] = userSelectedOption;

        const isCorrect = (userSelectedOption === currentQ.correct);
        if (isCorrect) {
          correctCount++;
          userXP += 15;
          document.getElementById('user-xp').textContent = `${userXP} XP`;
        } else {
          wrongCount++;
        }

        // Highlight options
        const correctBtn = document.getElementById(`quiz-opt-${currentQ.correct}`);
        if (correctBtn) correctBtn.classList.add('correct');

        if (!isCorrect) {
          const wrongBtn = document.getElementById(`quiz-opt-${userSelectedOption}`);
          if (wrongBtn) wrongBtn.classList.add('incorrect');
        }

        // Show feedback in bottom drawer
        const drawer = document.getElementById('bottom-drawer');
        const feedback = document.getElementById('drawer-feedback');
        const icon = document.getElementById('drawer-icon');
        const title = document.getElementById('drawer-title');
        const desc = document.getElementById('drawer-desc');
        const actionBtn = document.getElementById('btn-quiz-action');

        feedback.classList.remove('hidden');

        if (isCorrect) {
          drawer.className = 'border-t-2 border-emerald-200 p-4 sm:py-5 bg-emerald-50 text-emerald-950 transition-all';
          icon.className = 'w-10 h-10 rounded-2xl bg-emerald-500 text-white flex items-center justify-center text-xl font-black shrink-0';
          icon.innerHTML = '<i class="fa-solid fa-check"></i>';
          title.textContent = 'CHÍNH XÁC! Tuyệt vời lắm! 🎉 (+15 XP)';
          title.className = 'font-black text-emerald-700 text-sm sm:text-base';
          desc.innerHTML = currentQ.explanation || 'Đáp án hoàn toàn chuẩn xác theo hướng dẫn y khoa!';
          actionBtn.className = 'ml-auto px-8 py-3 rounded-2xl text-white font-black text-sm sm:text-base bg-emerald-600 hover:bg-emerald-500 shadow-sm';
        } else {
          drawer.className = 'border-t-2 border-duored-200 p-4 sm:py-5 bg-duored-50 text-duored-950 transition-all';
          icon.className = 'w-10 h-10 rounded-2xl bg-duored-600 text-white flex items-center justify-center text-xl font-black shrink-0';
          icon.innerHTML = '<i class="fa-solid fa-xmark"></i>';
          title.textContent = 'CHƯA ĐÚNG RỒI! Hãy xem lời giải nhé:';
          title.className = 'font-black text-duored-700 text-sm sm:text-base';
          desc.innerHTML = currentQ.explanation || 'Xem lại kiến thức lý thuyết của câu này để ghi nhớ nhé!';
          actionBtn.className = 'ml-auto px-8 py-3 rounded-2xl text-white font-black text-sm sm:text-base bg-duored-600 hover:bg-duored-500 shadow-sm';
        }

        actionBtn.textContent = isLastQuestion ? 'XEM KẾT QUẢ ➔' : 'CÂU TIẾP THEO ➔';

      } else {
        // Step 2: Next question or finish
        if (isLastQuestion) {
          finishQuiz();
        } else {
          currentQuestionIndex++;
          loadQuestion(currentQuestionIndex);
        }
      }
    }

    async function finishQuiz() {
      closeDuoModal();

      // Submit results to server
      try {
        await fetch('/medduo/api/submit', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            quiz_id: currentQuizDetail.id,
            answers: quizUserAnswers,
            total_time: 180
          })
        });
      } catch (e) {}

      // Show celebration modal
      document.getElementById('summary-correct').textContent = correctCount;
      document.getElementById('summary-wrong').textContent = wrongCount;
      document.getElementById('summary-xp').textContent = `+${correctCount * 15}`;
      document.getElementById('quiz-summary-modal').classList.remove('hidden');
    }

    function restartCurrentQuiz() {
      closeSummaryModal();
      if (currentQuizDetail) {
        startQuiz(currentQuizDetail.id);
      }
    }

    function closeSummaryModal() {
      document.getElementById('quiz-summary-modal').classList.add('hidden');
    }

    function closeDuoModal() {
      document.getElementById('duo-quiz-modal').classList.add('hidden');
      document.body.style.overflow = 'auto';
    }
  </script>
  {/literal}

</body>
</html>
