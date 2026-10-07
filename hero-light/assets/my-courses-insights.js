(() => {
  'use strict';

  // Preview-only learner analytics. Course names and lesson totals come from the Meduc catalog.
  const samples = {
    48: {
      label: 'Sinh lý học', symbol: 'i-activity', scores: [47, 51, 54, 59, 64, 70, 78],
      ability: [82, 74, 67, 63, 70], hours: '11,5', wrong: 12,
      questions: [
        ['Chức năng thận', 'Đơn vị chức năng cơ bản của thận là gì?', 'Cầu thận', 'Nephron', 'Nephron gồm cầu thận và hệ thống ống thận, đảm nhiệm quá trình tạo nước tiểu.'],
        ['Tuần hoàn', 'Buồng tim nào nhận máu từ tĩnh mạch chủ trên?', 'Thất phải', 'Nhĩ phải', 'Tĩnh mạch chủ trên đưa máu trở về nhĩ phải.'],
        ['Hô hấp', 'Hemoglobin trong hồng cầu vận chuyển chủ yếu khí nào?', 'Nitơ', 'Oxy', 'Hemoglobin gắn với oxy tại phổi và phân phối đến các mô.'],
      ],
    },
    99: {
      label: 'Giải phẫu', symbol: 'i-layers', scores: [42, 45, 52, 53, 60, 66, 71],
      ability: [76, 83, 62, 68, 57], hours: '7,5', wrong: 9,
      questions: [
        ['Hệ xương', 'Xương đùi thuộc phần nào của cơ thể?', 'Chi trên', 'Chi dưới', 'Xương đùi nằm giữa khớp háng và khớp gối.'],
        ['Lồng ngực', 'Tim nằm chủ yếu ở vùng nào của trung thất?', 'Trung thất sau', 'Trung thất giữa', 'Tim và màng ngoài tim nằm trong trung thất giữa.'],
        ['Hệ thần kinh', 'Tiểu não có vai trò nổi bật trong chức năng nào?', 'Tạo hormone', 'Phối hợp vận động', 'Tiểu não góp phần điều hòa tư thế và phối hợp vận động.'],
      ],
    },
    112: {
      label: 'Điện tâm đồ', symbol: 'i-heart', scores: [41, 46, 49, 55, 58, 64, 66],
      ability: [65, 71, 80, 73, 77], hours: '5', wrong: 7,
      questions: [
        ['ECG cơ bản', 'Sóng P trên điện tâm đồ thể hiện quá trình nào?', 'Khử cực thất', 'Khử cực nhĩ', 'Sóng P tương ứng với quá trình khử cực nhĩ.'],
        ['ECG cơ bản', 'Phức bộ QRS chủ yếu thể hiện quá trình nào?', 'Tái cực nhĩ', 'Khử cực thất', 'Phức bộ QRS biểu diễn quá trình khử cực hai thất.'],
        ['Khoảng thời gian', 'Khoảng PR phản ánh chủ yếu điều gì?', 'Thời gian tái cực thất', 'Dẫn truyền từ nhĩ đến thất', 'Khoảng PR được tính từ đầu sóng P đến đầu phức bộ QRS.'],
      ],
    },
    51: {
      label: 'Lâm sàng nội khoa', symbol: 'i-activity', scores: [61, 65, 68, 74, 78, 82, 87],
      ability: [89, 84, 79, 87, 83], hours: '34', wrong: 19,
      questions: [
        ['Khám lâm sàng', 'Thang điểm Glasgow được dùng để đánh giá điều gì?', 'Độ đau', 'Mức độ ý thức', 'Thang Glasgow đánh giá đáp ứng mở mắt, lời nói và vận động.'],
        ['Dấu hiệu sinh tồn', 'SpO₂ phản ánh chỉ số nào?', 'Đường huyết', 'Độ bão hòa oxy ngoại vi', 'SpO₂ là ước tính không xâm lấn về độ bão hòa oxy của hemoglobin.'],
        ['Tim mạch', 'Huyết áp tâm thu được ghi ở thời điểm nào?', 'Tim giãn tối đa', 'Tim co bóp', 'Huyết áp tâm thu là áp lực động mạch cao nhất trong chu kỳ tim.'],
      ],
    },
  };
  const skillLabels = ['Nền tảng', 'Ghi nhớ', 'Phân tích', 'Ứng dụng', 'Lâm sàng'];
  const escape = (value) => String(value).replace(/[&<>"']/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char]);

  function trendSvg(scores) {
    const x = (index) => 54 + index * 91;
    const y = (score) => 215 - (score - 40) * 3.15;
    const points = scores.map((score, index) => [x(index), y(score)]);
    const line = points.map((point, index) => (index ? 'L' : 'M') + point[0].toFixed(1) + ' ' + point[1].toFixed(1)).join(' ');
    const area = line + ' L600 215 L54 215 Z';
    const grid = [40, 60, 80, 100].map((score) => '<g><line x1="54" y1="' + y(score) + '" x2="600" y2="' + y(score) + '" class="insights-grid-line"/><text x="42" y="' + (y(score) + 4) + '" text-anchor="end">' + score + '</text></g>').join('');
    const dates = scores.map((_, index) => '<text x="' + x(index) + '" y="249" text-anchor="middle">B' + (index + 1) + '</text>').join('');
    const dots = points.map((point, index) => '<circle cx="' + point[0] + '" cy="' + point[1] + '" r="' + (index === points.length - 1 ? 6 : 3) + '" class="insights-trend-dot"/>').join('');
    return '<svg viewBox="0 0 640 265" role="img" aria-label="Điểm luyện tập minh họa tăng từ ' + scores[0] + ' đến ' + scores[scores.length - 1] + ' qua bảy buổi"><defs><linearGradient id="insights-area-fill" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#e52750" stop-opacity=".38"/><stop offset="1" stop-color="#e52750" stop-opacity="0"/></linearGradient></defs>' + grid + '<path d="' + area + '" fill="url(#insights-area-fill)"/><path d="' + line + '" class="insights-trend-line"/>' + dots + dates + '</svg>';
  }

  function radarSvg(values) {
    const cx = 180; const cy = 155; const radius = 100;
    const point = (index, scale) => {
      const angle = -Math.PI / 2 + index * Math.PI * 2 / 5;
      return [(cx + Math.cos(angle) * radius * scale).toFixed(1), (cy + Math.sin(angle) * radius * scale).toFixed(1)];
    };
    const polygon = (scale) => values.map((_, index) => point(index, scale).join(',')).join(' ');
    const rings = [.25, .5, .75, 1].map((scale) => '<polygon points="' + polygon(scale) + '" class="insights-radar-ring"/>').join('');
    const axes = values.map((_, index) => { const p = point(index, 1); return '<line x1="' + cx + '" y1="' + cy + '" x2="' + p[0] + '" y2="' + p[1] + '" class="insights-radar-axis"/>'; }).join('');
    const shape = values.map((value, index) => point(index, value / 100).join(',')).join(' ');
    const dots = values.map((value, index) => { const p = point(index, value / 100); return '<circle cx="' + p[0] + '" cy="' + p[1] + '" r="4" class="insights-radar-dot"/>'; }).join('');
    const labels = skillLabels.map((label, index) => { const p = point(index, 1.32); const anchor = Number(p[0]) < 145 ? 'end' : Number(p[0]) > 215 ? 'start' : 'middle'; return '<text x="' + p[0] + '" y="' + p[1] + '" text-anchor="' + anchor + '">' + escape(label) + '</text>'; }).join('');
    return '<svg viewBox="0 0 360 320" role="img" aria-label="Bản đồ năng lực minh họa: ' + skillLabels.map((label, index) => label + ' ' + values[index] + ' phần trăm').join(', ') + '">' + rings + axes + '<polygon points="' + shape + '" class="insights-radar-shape"/>' + dots + labels + '</svg>';
  }

  function renderKpis(item, sample) {
    const metrics = [
      ['BÀI ĐÃ HỌC', item.completed + '<small> / ' + item.lessons + '</small>', item.percent + '% hành trình'],
      ['ĐIỂM LUYỆN TẬP', sample.scores[6] + '<small> / 100</small>', '+' + (sample.scores[6] - sample.scores[0]) + ' điểm sau 7 buổi'],
      ['THỜI GIAN HỌC', sample.hours + '<small> giờ</small>', 'Tích lũy trong khóa'],
      ['CÂU CẦN ÔN LẠI', sample.wrong + '<small> câu</small>', '3 câu mẫu bên dưới'],
    ];
    document.getElementById('insights-kpis').innerHTML = metrics.map((metric, index) => '<div class="insights-kpi"><span>0' + (index + 1) + ' / ' + metric[0] + '</span><strong>' + metric[1] + '</strong><small>' + metric[2] + '</small></div>').join('');
  }

  function renderQuestions(sample) {
    document.getElementById('insights-notebook-count').innerHTML = '<strong>' + sample.wrong + '</strong><span>câu cần ôn lại<br/><small>3 câu minh họa gần đây</small></span>';
    document.getElementById('insights-question-list').innerHTML = sample.questions.map((question, index) => '<details class="insights-question"><summary><span class="insights-question-number">0' + (index + 1) + '</span><span class="insights-question-main"><small>' + escape(question[0]) + '</small><strong>' + escape(question[1]) + '</strong></span><span class="insights-question-toggle" aria-hidden="true">+</span></summary><div class="insights-answer"><p><span>BẠN ĐÃ CHỌN</span><del>' + escape(question[2]) + '</del></p><p><span>ĐÁP ÁN ĐÚNG</span><strong>' + escape(question[3]) + '</strong></p><p class="insights-answer-note">' + escape(question[4]) + '</p></div></details>').join('');
  }

  window.renderMyCoursesInsights = (items) => {
    const available = items.filter((item) => samples[item.id]);
    const tabs = document.getElementById('insights-course-tabs');
    if (!available.length || !tabs) return;
    tabs.innerHTML = available.map((item, index) => '<button type="button" role="tab" id="insights-tab-' + item.id + '" aria-controls="insights-kpis" aria-selected="' + (index === 0) + '" tabindex="' + (index === 0 ? '0' : '-1') + '" data-course="' + item.id + '"><svg class="icon" aria-hidden="true"><use href="#' + samples[item.id].symbol + '"/></svg><span>' + escape(samples[item.id].label) + '</span></button>').join('');
    const buttons = [...tabs.querySelectorAll('button')];
    const render = (item) => {
      const sample = samples[item.id];
      buttons.forEach((button) => { const active = Number(button.dataset.course) === item.id; button.setAttribute('aria-selected', String(active)); button.tabIndex = active ? 0 : -1; });
      document.getElementById('insights-course-name').textContent = item.title + ' · ' + item.chapters + ' chương · ' + item.lessons + ' bài học';
      const url = (location.pathname.endsWith('/my-courses.html') ? 'course-detail.html' : '/khoa-hoc-chi-tiet-v2') + '?course=' + encodeURIComponent(item.url.slice(1));
      document.getElementById('insights-course-link').href = url;
      renderKpis(item, sample);
      document.getElementById('insights-trend-graph').innerHTML = trendSvg(sample.scores);
      document.getElementById('insights-trend-change').textContent = '+' + (sample.scores[6] - sample.scores[0]) + ' điểm';
      document.getElementById('insights-radar').innerHTML = radarSvg(sample.ability);
      renderQuestions(sample);
    };
    buttons.forEach((button, index) => {
      button.addEventListener('click', () => render(available[index]));
      button.addEventListener('keydown', (event) => {
        let next = index;
        if (event.key === 'ArrowRight') next = (index + 1) % buttons.length;
        else if (event.key === 'ArrowLeft') next = (index - 1 + buttons.length) % buttons.length;
        else if (event.key === 'Home') next = 0;
        else if (event.key === 'End') next = buttons.length - 1;
        else return;
        event.preventDefault(); buttons[next].focus(); render(available[next]);
      });
    });
    render(available[0]);
  };
})();
