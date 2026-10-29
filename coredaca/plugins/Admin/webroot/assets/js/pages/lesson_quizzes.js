/* "Bài tập của buổi" trong form khóa học (element/attribute/album_image_item.tpl, thuộc tính danhsachtiethoc).
   Mỗi buổi có một danh sách đề theo thứ tự: thêm bằng cách tìm tên hoặc mã đề, đổi thứ tự, xóa, và bật "Làm thử
   miễn phí" cho từng đề. Danh sách lưu vào ô ẩn quizzes_xx dạng JSON [{"id":75,"free":"y"}]; ô ẩn quiz_id_xx giữ đề
   đầu tiên. Buổi lưu trước đây chỉ có quiz_id_xx: đề đó miễn phí khi buổi là "Bài học thử".
   Thêm buổi mới (nút "Thêm bản ghi" của main.js) chép buổi đầu tiên rồi xóa giá trị: danh sách được vẽ lại theo ô ẩn. */
"use strict";

var nhLessonQuizzes = {
  info: {}, // id đề -> { name, count, staff_only }

  init: function () {
    var self = this;
    var widgets = $("[data-lesson-quizzes]");
    if (!widgets.length) return;

    widgets.each(function () { self.render($(this)); });
    self.loadInfo(widgets);
    self.events();
    $('#course-kind').on('change', function () {
      $('[data-lesson-quizzes]').each(function () {self.render($(this));});
    });

    // Buổi mới được thêm vào danh sách: vẽ lại danh sách đề của nó.
    document.querySelectorAll(".wrap-manager .list-item").forEach(function (list) {
      new MutationObserver(function (changes) {
        changes.forEach(function (change) {
          change.addedNodes.forEach(function (node) {
            if (node.nodeType === 1) $(node).find("[data-lesson-quizzes]").each(function () { self.render($(this)); });
          });
        });
      }).observe(list, { childList: true });
    });
  },

  // Danh sách đề của một buổi, đọc từ ô ẩn (hoặc từ mã đề cũ).
  read: function (widget) {
    var raw = $.trim(widget.find("[data-lesson-quizzes-value]").val() || "");
    if (raw !== "") {
      try {
        var list = JSON.parse(raw);
        if (Array.isArray(list)) {
          return list
            .map(function (item) { return { id: parseInt(item && item.id, 10) || 0, free: item && item.free === "y" }; })
            .filter(function (item) { return item.id > 0; });
        }
      } catch (error) {}
    }
    var first = parseInt($.trim(widget.find("[data-lesson-quizzes-first]").val() || ""), 10) || 0;
    if (!first) return [];
    var lang = widget.data("lang");
    var trial = widget.closest(".wrap-item").find('[data-name="trial_' + lang + '"]').val() === "y";
    return [{ id: first, free: trial }];
  },

  write: function (widget, list) {
    widget.find("[data-lesson-quizzes-value]").val(JSON.stringify(list.map(function (item) {
      return { id: item.id, free: item.free ? "y" : "n" };
    })));
    widget.find("[data-lesson-quizzes-first]").val(list.length ? list[0].id : "");
    this.render(widget, list);
  },

  render: function (widget, list) {
    var self = this;
    var kind = $('#course-kind').val();
    widget.toggle(kind !== 'knowledge' && kind !== 'exam_solution');
    list = list || self.read(widget);
    widget.find('.nh-lesson-quiz-add').toggle(kind !== 'quiz' || list.length < 2);
    var holder = widget.find("[data-lesson-quizzes-list]").empty();
    if (!list.length) {
      holder.append('<div class="nh-lesson-quiz-empty text-muted">Lưu khoá trắc nghiệm để tự tạo 2 bài tập cho bài này.</div>');
      return;
    }
    list.forEach(function (item, index) {
      var info = self.info[item.id];
      var row = $('<div class="nh-lesson-quiz"></div>').attr("data-id", item.id);
      var text = $('<div class="nh-lesson-quiz-name"></div>');
      text.append($("<strong></strong>").text(info && info.name ? info.name : "Đề #" + item.id));
      text.append($('<a target="_blank" rel="noopener" class="ml-3">Sửa câu hỏi</a>').attr('href', adminPath + '/quiz/update/' + item.id));
      var meta = ["Mã " + item.id];
      if (kind === 'quiz') meta.push(index === 0 ? 'Miễn phí · cần đủ 30 câu' : 'Trả phí theo môn');
      if (info && info.count) meta.push(info.count + " câu");
      if (info === null) meta.push("không tìm thấy đề này");
      if (info && info.staff_only) meta.push("đề nội bộ, học viên chưa làm được");
      text.append($('<span class="text-muted"></span>').text(" · " + meta.join(" · ")));
      if (info === null || (info && info.staff_only)) row.addClass("is-warning");

      var free = $('<label class="nh-lesson-quiz-free kt-checkbox kt-checkbox--brand mb-0"><input type="checkbox" data-lesson-quiz-free> Làm thử miễn phí<span></span></label>');
      free.find("input").prop("checked", kind === "quiz" ? index === 0 : item.free).prop("disabled", kind === "quiz");

      var tools = $('<div class="nh-lesson-quiz-tools"></div>');
      tools.append(
        $('<button type="button" class="btn btn-sm btn-clean btn-icon" title="Lên trên" data-lesson-quiz-move="-1"><i class="la la-arrow-up"></i></button>').prop("disabled", index === 0),
        $('<button type="button" class="btn btn-sm btn-clean btn-icon" title="Xuống dưới" data-lesson-quiz-move="1"><i class="la la-arrow-down"></i></button>').prop("disabled", index === list.length - 1),
        $('<button type="button" class="btn btn-sm btn-clean btn-icon" title="Bỏ đề khỏi buổi" data-lesson-quiz-remove><i class="la la-close"></i></button>')
      );
      row.append($('<span class="nh-lesson-quiz-number"></span>').text(index + 1), text, free, tools);
      holder.append(row);
    });
  },

  // Tên và số câu của các đề đang có trên trang, lấy một lần.
  loadInfo: function (widgets) {
    var self = this;
    var ids = [];
    widgets.each(function () {
      self.read($(this)).forEach(function (item) { if (ids.indexOf(item.id) < 0) ids.push(item.id); });
    });
    if (!ids.length) return;
    nhMain.callAjax({ url: adminPath + "/quiz/lesson-suggest", data: { ids: ids }, not_show_error: true }).done(function (response) {
      var found = {};
      (response && response.data ? response.data : []).forEach(function (quiz) { found[quiz.id] = quiz; });
      ids.forEach(function (id) { self.info[id] = found[id] || null; });
      widgets.each(function () { self.render($(this)); });
    });
  },

  events: function () {
    var self = this;
    var timer = null;

    $(document).on("change", "[data-lesson-quiz-free]", function () {
      var widget = $(this).closest("[data-lesson-quizzes]");
      var id = parseInt($(this).closest(".nh-lesson-quiz").attr("data-id"), 10);
      var checked = $(this).prop("checked");
      self.write(widget, self.read(widget).map(function (item) { return item.id === id ? { id: item.id, free: checked } : item; }));
    });

    $(document).on("click", "[data-lesson-quiz-move]", function () {
      var widget = $(this).closest("[data-lesson-quizzes]");
      var list = self.read(widget);
      var index = $(this).closest(".nh-lesson-quiz").index();
      var target = index + parseInt($(this).attr("data-lesson-quiz-move"), 10);
      if (target < 0 || target >= list.length) return;
      var moved = list.splice(index, 1)[0];
      list.splice(target, 0, moved);
      self.write(widget, list);
    });

    $(document).on("click", "[data-lesson-quiz-remove]", function () {
      var widget = $(this).closest("[data-lesson-quizzes]");
      var id = parseInt($(this).closest(".nh-lesson-quiz").attr("data-id"), 10);
      self.write(widget, self.read(widget).filter(function (item) { return item.id !== id; }));
    });

    // Tìm đề
    $(document).on("input", "[data-lesson-quizzes-search]", function () {
      var input = $(this);
      clearTimeout(timer);
      timer = setTimeout(function () { self.search(input); }, 250);
    });
    $(document).on("keydown", "[data-lesson-quizzes-search]", function (event) {
      if (event.key === "Enter") {
        // Enter không gửi form khóa học: chọn đề đầu tiên trong kết quả.
        event.preventDefault();
        $(this).closest("[data-lesson-quizzes]").find("[data-lesson-quizzes-results] button").first().trigger("click");
      } else if (event.key === "Escape") {
        $(this).closest("[data-lesson-quizzes]").find("[data-lesson-quizzes-results]").prop("hidden", true);
      }
    });
    $(document).on("click", function (event) {
      if (!$(event.target).closest(".nh-lesson-quiz-add").length) $("[data-lesson-quizzes-results]").prop("hidden", true);
    });
  },

  search: function (input) {
    var self = this;
    var widget = input.closest("[data-lesson-quizzes]");
    var results = widget.find("[data-lesson-quizzes-results]");
    var keyword = $.trim(input.val());
    input.data("asked", keyword);
    if (keyword.length < 1 || (keyword.length < 2 && !/^\d+$/.test(keyword))) {
      results.prop("hidden", true).empty();
      return;
    }
    nhMain.callAjax({ url: adminPath + "/quiz/lesson-suggest", data: { keyword: keyword }, not_show_error: true }).done(function (response) {
      if (input.data("asked") !== keyword) return;
      var quizzes = response && response.data ? response.data : [];
      var chosen = self.read(widget).map(function (item) { return item.id; });
      results.empty().prop("hidden", false);
      if (!quizzes.length) {
        results.append($('<div class="list-group-item text-muted"></div>').text("Không tìm thấy đề nào."));
        return;
      }
      quizzes.forEach(function (quiz) {
        var already = chosen.indexOf(quiz.id) >= 0;
        var label = (quiz.name || "Đề #" + quiz.id) + " · Mã " + quiz.id + (quiz.count ? " · " + quiz.count + " câu" : "") + (quiz.staff_only ? " · đề nội bộ" : "") + (already ? " · đã có trong buổi" : "");
        $('<button type="button" class="list-group-item list-group-item-action"></button>')
          .text(label)
          .prop("disabled", already)
          .on("click", function () {
            self.info[quiz.id] = quiz;
            var list = self.read(widget);
            if (list.some(function (item) { return item.id === quiz.id; })) return;
            list.push({ id: quiz.id, free: false });
            self.write(widget, list);
            input.val("").data("asked", "");
            results.prop("hidden", true).empty();
            input.trigger("focus");
          })
          .appendTo(results);
      });
    });
  },
};

$(document).ready(function () {
  nhLessonQuizzes.init();
});
