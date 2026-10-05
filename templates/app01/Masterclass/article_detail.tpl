<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tiếp Cận & Xử Trí Nhanh Cơn Đau Ngực Cấp - Tạp Chí Y Khoa MedUC</title>
  
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

  {literal}
  <style>
    body {
      font-family: 'Plus Jakarta Sans', sans-serif;
      background-color: #ffffff;
      color: #0f172a;
    }
    .sticky-sidebar {
      position: sticky;
      top: 6rem;
    }
    .article-body p {
      margin-bottom: 1.25rem;
      line-height: 1.85;
      font-size: 0.95rem;
      color: #334155;
    }
    .article-body h2 {
      font-size: 1.5rem;
      font-weight: 900;
      color: #0f172a;
      margin-top: 2.5rem;
      margin-bottom: 1rem;
      padding-bottom: 0.5rem;
      border-bottom: 2px solid #f1f5f9;
      letter-spacing: -0.02em;
    }
    .article-body h3 {
      font-size: 1.2rem;
      font-weight: 800;
      color: #0f172a;
      margin-top: 1.75rem;
      margin-bottom: 0.75rem;
    }
    .reading-progress-bar {
      position: fixed;
      top: 0;
      left: 0;
      height: 3.5px;
      background: #e11d48;
      z-index: 100;
      transition: width 0.1s ease;
    }
  </style>
  {/literal}
</head>
<body class="bg-white text-slate-900 antialiased min-h-screen flex flex-col font-sans">

  <!-- Top Reading Progress Indicator -->
  <div id="reading-bar" class="reading-progress-bar w-0"></div>

  <!-- ================= MEDUC OFFICIAL HEADER ================= -->
  {$this->element('layout/header_meduc')}

  <!-- ================= ARTICLE HERO BANNER ================= -->
  <article class="max-w-7xl mx-auto px-4 sm:px-6 pt-10 pb-16 w-full">
    
    <!-- Breadcrumb & Tags -->
    <div class="max-w-4xl mx-auto mb-6">
      <div class="flex flex-wrap items-center gap-2 text-xs font-bold text-slate-400 mb-4">
        <a href="/masterclass" class="hover:text-medred-600">Trang Chủ</a>
        <span>/</span>
        <a href="#" class="hover:text-medred-600">Kiến Thức Y Khoa</a>
        <span>/</span>
        <span class="text-medred-600">Tim Mạch Cấp Cứu</span>
      </div>

      <div class="flex flex-wrap items-center gap-2.5 mb-4">
        <span class="px-3 py-1 rounded-full text-xs font-black uppercase tracking-wider bg-rose-50 text-medred-700 border border-rose-200">
          <i class="fa-solid fa-bolt mr-1"></i> Hồi Sức Cấp Cứu
        </span>
        <span class="px-3 py-1 rounded-full text-xs font-black uppercase tracking-wider bg-slate-100 text-slate-700">
          Hướng Dẫn Lâm Sàng 2026
        </span>
        <span class="px-3 py-1 rounded-full text-xs font-black uppercase tracking-wider bg-emerald-50 text-emerald-700 border border-emerald-200 flex items-center gap-1">
          <i class="fa-solid fa-circle-check text-emerald-600"></i> Đã Bình Duyệt Y Khoa
        </span>
      </div>

      <!-- Main Headline -->
      <h1 class="text-3xl sm:text-5xl font-black text-slate-950 tracking-tight leading-[1.18] mb-6">
        Tiếp Cận & Xử Trí Nhanh Cơn Đau Ngực Cấp Tại Khoa Cấp Cứu: Từ Điện Tâm Đồ (ECG) Đến Quyết Định Can Thiệp Mạch Vành
      </h1>

      <!-- Author Bar & Metrics -->
      <div class="flex flex-wrap items-center justify-between gap-4 py-4 border-y border-slate-100 text-xs font-bold text-slate-500">
        <div class="flex items-center gap-3">
          <img 
            src="https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=200&auto=format&fit=crop&q=80" 
            alt="TS.BS CKII Nguyễn Văn An" 
            class="w-11 h-11 rounded-2xl object-cover border-2 border-medred-200"
          />
          <div>
            <div class="text-slate-900 font-black text-sm">TS.BS CKII Nguyễn Văn An</div>
            <div class="text-slate-400 font-medium">Bệnh viện Hữu nghị Việt Đức & Giảng viên MedUC</div>
          </div>
        </div>

        <div class="flex items-center gap-5 text-slate-400">
          <span class="flex items-center gap-1.5"><i class="fa-regular fa-clock text-medred-500"></i> 8 phút đọc</span>
          <span class="flex items-center gap-1.5"><i class="fa-solid fa-eye text-medred-500"></i> 14.280 lượt đọc</span>
          <span class="flex items-center gap-1.5"><i class="fa-regular fa-calendar text-medred-500"></i> 20/09/2026</span>
        </div>
      </div>
    </div>

    <!-- ================= 3-COLUMN EDITORIAL LAYOUT ================= -->
    <div class="grid grid-cols-1 lg:grid-cols-12 gap-10 items-start mt-8">
      
      <!-- LEFT COLUMN: TABLE OF CONTENTS (3 Cols) -->
      <aside class="hidden lg:block lg:col-span-3 sticky-sidebar">
        <div class="bg-slate-50 rounded-3xl p-5 border border-slate-200/80 space-y-4">
          <div class="text-xs font-black uppercase tracking-wider text-slate-400 flex items-center gap-2">
            <i class="fa-solid fa-list-ol text-medred-600"></i>
            <span>Mục Lục Bài Viết</span>
          </div>

          <nav class="space-y-2 text-xs font-bold text-slate-600">
            <a href="#section-1" class="block p-2 rounded-xl hover:bg-white hover:text-medred-600 transition text-medred-700 bg-white shadow-sm">
              1. Đánh giá ban đầu & Quy tắc ABC
            </a>
            <a href="#section-2" class="block p-2 rounded-xl hover:bg-white hover:text-medred-600 transition">
              2. Ca lâm sàng điển hình
            </a>
            <a href="#section-3" class="block p-2 rounded-xl hover:bg-white hover:text-medred-600 transition">
              3. Đọc nhanh ECG trong 10 phút đầu
            </a>
            <a href="#section-4" class="block p-2 rounded-xl hover:bg-white hover:text-medred-600 transition">
              4. Cảnh báo sống còn: Cạm bẫy lâm sàng
            </a>
            <a href="#section-5" class="block p-2 rounded-xl hover:bg-white hover:text-medred-600 transition">
              5. Bảng liều lượng thuốc cấp cứu
            </a>
            <a href="#section-6" class="block p-2 rounded-xl hover:bg-white hover:text-medred-600 transition">
              6. Thử thách trắc nghiệm nhanh
            </a>
          </nav>

          <div class="pt-4 border-t border-slate-200/80">
            <button onclick="alert('Đã sao chép liên kết bài viết vào bộ nhớ đệm!')" class="w-full py-2.5 rounded-xl border border-slate-200 bg-white hover:bg-slate-100 text-slate-700 text-xs font-black flex items-center justify-center gap-2 transition">
              <i class="fa-solid fa-share-nodes text-medred-600"></i>
              <span>Chia sẻ bài viết</span>
            </button>
          </div>
        </div>
      </aside>

      <!-- CENTER COLUMN: MAIN ARTICLE CONTENT (6 Cols) -->
      <main class="lg:col-span-6 article-body min-w-0">
        
        <!-- Executive Clinical Summary Callout -->
        <div class="p-6 rounded-3xl bg-emerald-50 border border-emerald-200/90 text-emerald-950 mb-8">
          <div class="flex items-center gap-2 text-xs font-black uppercase tracking-wider text-emerald-700 mb-2">
            <i class="fa-solid fa-clipboard-check text-base"></i> TÓM TẮT THỰC HÀNH LÂM SÀNG (KEY TAKEAWAYS)
          </div>
          <ul class="text-xs font-bold text-emerald-900 space-y-2 list-disc list-inside leading-relaxed">
            <li>Bệnh nhân đau ngực cấp phải được đo và phân tích điện tâm đồ 12 chuyển đạo trong vòng <strong>dưới 10 phút</strong> kể từ khi tiếp xúc y tế.</li>
            <li>Nhồi máu cơ tim có ST chênh lên (STEMI) là chỉ định kích hoạt phòng can thiệp mạch vành (Cathlab) khẩn cấp, không chờ kết quả men tim Troponin!</li>
            <li>Luôn loại trừ 5 nguyên nhân đau ngực nguy hiểm đe dọa tính mạng: Hội chứng vành cấp, Bóc tách động mạch chủ ngực, Thuyên tắc phổi cấp, Tràn khí màng phổi áp lực và Vỡ thực quản.</li>
          </ul>
        </div>

        <section id="section-1">
          <h2>1. Đánh Giá Ban Đầu & Quy Tắc ABC</h2>
          <p>
            Đau ngực cấp là một trong những lý do nhập viện cấp cứu phổ biến nhất nhưng cũng ẩn chứa tỷ lệ tử vong cao nhất nếu bác sĩ bỏ sót các bệnh cảnh tim mạch tối cấp.
          </p>
          <p>
            Ngay khi bệnh nhân bước vào phòng cấp cứu, việc đầu tiên người thầy thuốc cần thực hiện là đánh giá đường thở (Airway), nhịp thở (Breathing) và huyết động (Circulation). Đồng thời lắp máy monitor theo dõi liên tục huyết áp, nhịp tim và SpO2.
          </p>
        </section>

        <!-- Clinical Vignette Case Box -->
        <section id="section-2" class="my-8">
          <div class="p-6 rounded-3xl bg-slate-900 text-white shadow-xl relative overflow-hidden">
            <div class="flex items-center justify-between mb-3">
              <span class="px-2.5 py-0.5 rounded-full text-[10px] font-black uppercase tracking-wider bg-medred-600 text-white">
                Ca Lâm Sàng Minh Họa
              </span>
              <span class="text-xs text-slate-400 font-mono">CASE ID #CARDIO-882</span>
            </div>
            
            <h3 class="text-base font-black text-white mt-0 mb-2">Bệnh nhân nam 58 tuổi đau thắt ngực lan lên cằm</h3>
            <p class="text-xs text-slate-300 leading-relaxed font-medium mb-3">
              Bệnh nhân nam 58 tuổi, tiền sử hút thuốc lá 20 năm, tăng huyết áp điều trị không liên tục. Nhập viện vì đau tức ngực sau xương ức khởi phát cách 2 giờ lúc đang nghỉ ngơi, cảm giác đè nặng như đá đè, lan lên cằm và mặt trong cánh tay trái, kèm vã mồ hôi lạnh. Huyết áp 145/90 mmHg, SpO2 97%.
            </p>
            <div class="p-3 bg-slate-800/80 rounded-xl border border-slate-700/60 text-xs font-bold text-amber-300">
              ➔ Hướng xử trí đầu tiên: Ghi điện tâm đồ 12 chuyển đạo ngay lập tức tại giường bệnh!
            </div>
          </div>
        </section>

        <section id="section-3">
          <h2>3. Đọc Nhanh Điện Tâm Đồ (ECG) Trong 10 Phút Đầu</h2>
          <p>
            Điện tâm đồ là "vũ khí" chẩn đoán nhanh và rẻ tiền nhất nhưng có giá trị sinh mạng tối cao. Bác sĩ cần đối chiếu hình ảnh ST chênh lên ở các nhóm chuyển đạo tương ứng với vùng cơ tim bị tổn thương:
          </p>

          <!-- ECG Image with Clinical Annotation -->
          <div class="rounded-2xl overflow-hidden border border-slate-200 my-6 shadow-sm">
            <img 
              src="https://images.unsplash.com/photo-1628348068343-c6a848d2b6dd?w=800&auto=format&fit=crop&q=80" 
              alt="Dải điện tim ECG nhồi máu cơ tim" 
              class="w-full aspect-video object-cover"
            />
            <div class="p-4 bg-slate-50 border-t border-slate-200 text-xs font-medium text-slate-600">
              <strong class="text-slate-900 font-black">Hình 1:</strong> ST chênh lên dạng vòm (Pardee wave) > 2mm ở các chuyển đạo trước tim V1 - V4, gợi ý tắc hoàn toàn nhánh liên thất trước (LAD) nuôi thất trái.
            </div>
          </div>

          <p>
            Nếu phát hiện ST chênh lên có ý nghĩa trên 2 chuyển đạo liên tiếp cùng vùng, chẩn đoán xác định là <strong>Nhồi Máu Cơ Tim Cấp ST Chênh Lên (STEMI)</strong>. Ngay lập tức liên hệ đội ngũ can thiệp tim mạch, không trì hoãn chờ kết quả xét nghiệm máu!
          </p>
        </section>

        <!-- Red Clinical Pearl / Warning Box -->
        <section id="section-4" class="my-8">
          <div class="p-6 rounded-3xl bg-rose-50 border-2 border-medred-200 text-medred-950">
            <div class="flex items-center gap-2 text-xs font-black uppercase tracking-wider text-medred-700 mb-2">
              <i class="fa-solid fa-triangle-exclamation text-base text-medred-600"></i> CẢNH BÁO SỐNG CÒN: CẠM BẪY LÂM SÀNG CẦN NHỚ
            </div>
            <p class="text-xs font-bold text-medred-900 leading-relaxed mb-2">
              1. <strong>Tuyệt đối không dùng Nitroglycerin</strong> cho bệnh nhân nhồi máu cơ tim thất phải (ST chênh lên ở V3R, V4R) hoặc bệnh nhân có huyết áp tâm thu dưới 90 mmHg, vì có thể gây tụt huyết áp trụy mạch không hồi phục!
            </p>
            <p class="text-xs font-bold text-medred-900 leading-relaxed">
              2. Không loại trừ hội chứng vành cấp chỉ vì điện tâm đồ ban đầu bình thường. Có tới 15% ca nhồi máu cơ tim có ECG ban đầu không rõ ràng, cần đo lại sau mỗi 15 - 30 phút!
            </p>
          </div>
        </section>

        <!-- Section 5: Drug Protocol Table -->
        <section id="section-5">
          <h2>5. Bảng Liều Lượng Thuốc Cấp Cứu Ban Đầu</h2>
          <p>
            Gói điều trị ban đầu thường được tóm tắt bằng phác đồ MONA (Morphin, Oxy, Nitrat, Aspirin) có điều chỉnh theo hướng dẫn mới nhất của Hội Tim Mạch Việt Nam:
          </p>

          <div class="overflow-x-auto rounded-2xl border border-slate-200 my-6 shadow-sm">
            <table class="w-full text-left text-xs font-bold">
              <thead class="bg-slate-100 text-slate-800 uppercase tracking-wider text-[11px] border-b border-slate-200">
                <tr>
                  <th class="p-3.5">Tên thuốc</th>
                  <th class="p-3.5">Liều tấn công ban đầu</th>
                  <th class="p-3.5">Đường dùng & Lưu ý</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-slate-100 text-slate-600">
                <tr class="hover:bg-slate-50 transition">
                  <td class="p-3.5 text-slate-900 font-black">Aspirin</td>
                  <td class="p-3.5 text-medred-600">150 - 300 mg</td>
                  <td class="p-3.5">Nhai trực tiếp để hấp thu nhanh qua niêm mạc miệng.</td>
                </tr>
                <tr class="hover:bg-slate-50 transition">
                  <td class="p-3.5 text-slate-900 font-black">Ticagrelor hoặc Clopidogrel</td>
                  <td class="p-3.5 text-medred-600">180 mg (Ticagrelor) / 300-600 mg (Clopidogrel)</td>
                  <td class="p-3.5">Thuốc kháng kết tập tiểu cầu thứ 2 (DAPT). Uống ngay.</td>
                </tr>
                <tr class="hover:bg-slate-50 transition">
                  <td class="p-3.5 text-slate-900 font-black">Nitroglycerin</td>
                  <td class="p-3.5 text-medred-600">0.4 mg</td>
                  <td class="p-3.5">Ngậm dưới lưỡi mỗi 5 phút (tối đa 3 lần). Chống chỉ định nếu HA &lt; 90.</td>
                </tr>
                <tr class="hover:bg-slate-50 transition">
                  <td class="p-3.5 text-slate-900 font-black">Heparin không phân đoạn (UFH)</td>
                  <td class="p-3.5 text-medred-600">60 IU/kg (tối đa 4000 IU)</td>
                  <td class="p-3.5">Tiêm tĩnh mạch bolus trước khi đưa vào phòng Cathlab.</td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>

        <!-- Section 6: Interactive Quick Quiz Widget (MedDuo Style) -->
        <section id="section-6" class="my-10 pt-6 border-t border-slate-200">
          <div class="p-6 rounded-3xl bg-slate-900 text-white shadow-xl">
            <div class="flex items-center justify-between mb-3">
              <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-medred-600 text-white text-[11px] font-black uppercase">
                <i class="fa-solid fa-gamepad"></i> THỬ THÁCH NHANH SAU BÀI ĐỌC (+15 XP)
              </span>
              <span class="text-xs font-bold text-amber-400">MedDuo Mini</span>
            </div>

            <h3 class="text-base font-black text-white mt-0 mb-4 leading-snug">
              Câu hỏi: Bệnh nhân nhồi máu cơ tim cấp có huyết áp 80/50 mmHg kèm ST chênh lên ở V3R, V4R. Thuốc nào sau đây TUYỆT ĐỐI CHỐNG CHỈ ĐỊNH?
            </h3>

            <div class="space-y-2.5 text-xs font-bold text-slate-800" id="quiz-options-box">
              <button onclick="checkArticleQuiz(0)" id="art-opt-0" class="w-full text-left p-3.5 rounded-xl bg-white hover:bg-slate-100 flex items-center gap-2.5 transition">
                <span class="w-6 h-6 rounded-lg bg-slate-100 font-black flex items-center justify-center text-[11px]">A</span>
                <span>Truyền dung dịch muối đẳng trương 0.9%</span>
              </button>
              <button onclick="checkArticleQuiz(1)" id="art-opt-1" class="w-full text-left p-3.5 rounded-xl bg-white hover:bg-slate-100 flex items-center gap-2.5 transition">
                <span class="w-6 h-6 rounded-lg bg-slate-100 font-black flex items-center justify-center text-[11px]">B</span>
                <span>Nitroglycerin ngậm dưới lưỡi</span>
              </button>
              <button onclick="checkArticleQuiz(2)" id="art-opt-2" class="w-full text-left p-3.5 rounded-xl bg-white hover:bg-slate-100 flex items-center gap-2.5 transition">
                <span class="w-6 h-6 rounded-lg bg-slate-100 font-black flex items-center justify-center text-[11px]">C</span>
                <span>Aspirin 300 mg nhai</span>
              </button>
              <button onclick="checkArticleQuiz(3)" id="art-opt-3" class="w-full text-left p-3.5 rounded-xl bg-white hover:bg-slate-100 flex items-center gap-2.5 transition">
                <span class="w-6 h-6 rounded-lg bg-slate-100 font-black flex items-center justify-center text-[11px]">D</span>
                <span>Kích hoạt phòng can thiệp mạch vành Cathlab</span>
              </button>
            </div>

            <div id="art-feedback" class="hidden mt-4 p-3.5 rounded-xl text-xs font-bold"></div>
          </div>
        </section>

      </main>

      <!-- RIGHT COLUMN: STICKY CONVERSION WIDGETS (3 Cols) -->
      <aside class="hidden lg:block lg:col-span-3 sticky-sidebar space-y-6">
        
        <!-- Widget 1: Related Course -->
        <div class="bg-white rounded-3xl p-5 border border-slate-200 shadow-lg space-y-4">
          <span class="text-[10px] font-black uppercase tracking-wider text-medred-600 bg-medred-50 px-2.5 py-1 rounded-lg">
            Khóa Học Liên Quan
          </span>

          <div class="aspect-video rounded-2xl overflow-hidden bg-slate-900 relative">
            <img src="https://images.unsplash.com/photo-1628348068343-c6a848d2b6dd?w=400&auto=format&fit=crop&q=80" alt="ECG" class="w-full h-full object-cover" />
            <div class="absolute inset-0 bg-black/30 flex items-center justify-center">
              <i class="fa-solid fa-play text-white text-base"></i>
            </div>
          </div>

          <h4 class="font-black text-slate-900 text-sm leading-snug">
            THE ECG IN PRACTICE & Đọc Nhanh Điện Tâm Đồ Cấp Cứu
          </h4>
          <p class="text-[11px] text-slate-500 font-medium">Học cách phân tích 100+ ca rối loạn nhịp nguy hiểm cùng chuyên gia Tim mạch.</p>

          <div class="pt-2 flex items-center justify-between">
            <div>
              <div class="text-[10px] text-slate-400 line-through">170.000đ</div>
              <div class="text-sm font-black text-medred-600">150.000đ</div>
            </div>
            <a href="/course-detail" class="px-3 py-1.5 rounded-xl bg-slate-900 hover:bg-medred-600 text-white font-black text-xs transition">
              Xem Khóa Học
            </a>
          </div>
        </div>

        <!-- Widget 2: MedDuo Quiz Promotion -->
        <div class="bg-gradient-to-br from-orange-50 to-medred-50 rounded-3xl p-5 border border-orange-200/80 shadow-sm space-y-3">
          <div class="flex items-center gap-2 text-orange-600 font-black text-xs uppercase">
            <i class="fa-solid fa-fire text-base"></i>
            <span>Bộ Đề Trắc Nghiệm</span>
          </div>
          <h4 class="font-black text-slate-900 text-sm">
            Luyện 35 Câu Hỏi Dược Lý & Cấp Cứu Tim Mạch
          </h4>
          <p class="text-[11px] text-slate-600 font-medium">
            Có đầy đủ lời giải thích chi tiết bệnh học và cộng điểm Streak thi đua cùng 12.000 sinh viên Y.
          </p>
          <a href="/medduo" class="block w-full py-2.5 rounded-xl bg-medred-600 hover:bg-medred-700 text-white font-black text-xs text-center shadow-md transition">
            Luyện Đề Ngay (Miễn Phí)
          </a>
        </div>

      </aside>

    </div>
  </article>

  <!-- Footer -->
  <footer class="bg-slate-950 text-slate-400 py-10 text-xs font-semibold border-t border-slate-800 mt-auto">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 flex flex-col sm:flex-row items-center justify-between gap-4">
      <div class="flex items-center gap-2">
        <div class="w-6 h-6 rounded-lg bg-medred-600 text-white flex items-center justify-center text-xs font-black">
          <i class="fa-solid fa-heart-pulse"></i>
        </div>
        <span class="text-white font-black">MedUC Journal</span>
        <span>• Kiến Thức Y Khoa Chuẩn Bộ Y Tế</span>
      </div>
      <div class="flex items-center gap-3">
        <a href="/masterclass" class="text-slate-400 hover:text-white transition">Trang Chủ MasterClass</a>
        <span>•</span>
        <a href="/medduo" class="text-slate-400 hover:text-white transition">Luyện Đề MedDuo</a>
      </div>
    </div>
  </footer>

  <!-- Reading Progress Bar & Quick Quiz JavaScript -->
  {literal}
  <script>
    // Reading progress bar calculation on scroll
    window.addEventListener('scroll', () => {
      const winScroll = document.body.scrollTop || document.documentElement.scrollTop;
      const height = document.documentElement.scrollHeight - document.documentElement.clientHeight;
      const scrolled = (winScroll / height) * 100;
      document.getElementById('reading-bar').style.width = scrolled + '%';
    });

    // Quick quiz interactive engine
    let quizDone = false;
    function checkArticleQuiz(selectedIdx) {
      if (quizDone) return;
      quizDone = true;

      const correctIdx = 1; // B: Nitroglycerin
      const feedback = document.getElementById('art-feedback');
      feedback.classList.remove('hidden');

      if (selectedIdx === correctIdx) {
        document.getElementById(`art-opt-${selectedIdx}`).className = 'w-full text-left p-3.5 rounded-xl bg-emerald-500 text-white font-black flex items-center gap-2.5 transition';
        feedback.className = 'mt-4 p-3.5 rounded-xl text-xs font-bold bg-emerald-500/20 text-emerald-300 border border-emerald-500/40';
        feedback.innerHTML = '🎉 <strong>CHÍNH XÁC (+15 XP)!</strong> Nitroglycerin làm giãn tĩnh mạch giảm tiền gánh, ở bệnh nhân nhồi máu cơ tim thất phải đang phụ thuộc tiền gánh sẽ gây tụt huyết áp sốc tim rất nguy kịch!';
      } else {
        document.getElementById(`art-opt-${selectedIdx}`).className = 'w-full text-left p-3.5 rounded-xl bg-rose-600 text-white font-black flex items-center gap-2.5 transition';
        document.getElementById(`art-opt-${correctIdx}`).className = 'w-full text-left p-3.5 rounded-xl bg-emerald-500 text-white font-black flex items-center gap-2.5 transition';
        feedback.className = 'mt-4 p-3.5 rounded-xl text-xs font-bold bg-rose-500/20 text-rose-300 border border-rose-500/40';
        feedback.innerHTML = '❌ <strong>CHƯA ĐÚNG!</strong> Đáp án đúng là <strong>B. Nitroglycerin</strong>. Nhồi máu thất phải làm thất phải giảm tống máu, cần duy trì thể tích tuần hoàn và tiền gánh, dùng Nitrat sẽ làm tụt HA đột ngột!';
      }
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
