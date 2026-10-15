/* Ghi danh khóa học (templates/CourseEnrollment/list.tpl, update.tpl).
   - Danh sách: Tạm khóa / Mở lại / Xóa một ghi danh rồi tải lại trang.
   - Form: tìm học viên theo tên, mã, điện thoại, email; lưu rồi về danh sách. */
"use strict";

var nhCourseEnrollment = {
  init: function () {
    this.list();
    this.form();
  },

  respond: function (response, onSuccess) {
    if (response && response.code == _SUCCESS) {
      onSuccess(response);
    } else {
      toastr.error(response && response.message ? response.message : nhMain.getLabel("cap_nhat_khong_thanh_cong"));
    }
  },

  list: function () {
    var self = this;

    $(document).on("click", "[data-enrollment-status]", function () {
      var row = $(this).closest("tr");
      nhMain
        .callAjax({
          url: adminPath + "/course-enrollment/change-status",
          data: { ids: [row.data("id")], status: $(this).attr("data-enrollment-status") },
        })
        .done(function (response) {
          self.respond(response, function () { location.reload(); });
        });
    });

    $(document).on("click", "[data-enrollment-delete]", function () {
      var row = $(this).closest("tr");
      swal
        .fire({
          title: "Xóa ghi danh",
          text: "Học viên sẽ không còn học được khóa này trên website (trừ khi có lớp học cũ). Xóa ghi danh?",
          type: "warning",
          confirmButtonText: '<i class="la la-trash-o"></i>' + nhMain.getLabel("dong_y"),
          confirmButtonClass: "btn btn-sm btn-danger",
          showCancelButton: true,
          cancelButtonText: nhMain.getLabel("huy_bo"),
          cancelButtonClass: "btn btn-sm btn-default",
        })
        .then(function (result) {
          if (!result || !result.value) return;
          nhMain
            .callAjax({ url: adminPath + "/course-enrollment/delete", data: { ids: [row.data("id")] } })
            .done(function (response) {
              self.respond(response, function () { location.reload(); });
            });
        });
    });
  },

  form: function () {
    var self = this;
    var form = $("#enrollment-form");
    if (!form.length) return;

    // Học viên
    var pick = form.find("[data-enrollment-customer]");
    var input = pick.find("[data-enrollment-customer-search]");
    var results = pick.find("[data-enrollment-customer-results]");
    var chosen = pick.find("[data-enrollment-customer-chosen]");
    var timer = null;
    var asked = "";

    var label = function (customer) {
      var parts = [customer.code, customer.phone, customer.email].filter(function (part) { return part; });
      return (customer.full_name || "Học viên #" + customer.id) + (parts.length ? " · " + parts.join(" · ") : "");
    };
    var choose = function (customer) {
      pick.find('[name="customer_id"]').val(customer.id);
      pick.find("[data-enrollment-customer-label]").text(label(customer));
      input.closest(".kt-input-icon").prop("hidden", true);
      results.prop("hidden", true).empty();
      chosen.prop("hidden", false).addClass("d-flex align-items-center");
    };
    var search = function () {
      var keyword = $.trim(input.val());
      if (keyword === asked) return;
      asked = keyword;
      if (keyword.length < 2) {
        results.prop("hidden", true).empty();
        return;
      }
      nhMain
        .callAjax({ url: adminPath + "/course-enrollment/customer-suggest", data: { keyword: keyword } })
        .done(function (response) {
          if (keyword !== asked) return;
          var customers = response && response.data ? response.data : [];
          results.empty().prop("hidden", false);
          if (!customers.length) {
            results.append($('<div class="list-group-item text-muted"></div>').text("Không tìm thấy học viên nào."));
            return;
          }
          customers.forEach(function (customer) {
            $('<button type="button" class="list-group-item list-group-item-action"></button>')
              .text(label(customer))
              .on("click", function () { choose(customer); })
              .appendTo(results);
          });
        });
    };

    input.on("input", function () {
      clearTimeout(timer);
      timer = setTimeout(search, 250);
    });
    input.on("keydown", function (event) {
      if (event.key === "Enter") {
        event.preventDefault();
        results.find("button").first().trigger("click");
      }
    });
    pick.find("[data-enrollment-customer-clear]").on("click", function () {
      pick.find('[name="customer_id"]').val("");
      chosen.prop("hidden", true).removeClass("d-flex align-items-center");
      input.closest(".kt-input-icon").prop("hidden", false);
      asked = "";
      input.val("").trigger("focus");
    });

    // Lưu
    form.on("submit", function (event) {
      event.preventDefault();
      var button = $('[form="enrollment-form"][type="submit"]').prop("disabled", true);
      nhMain
        .callAjax({ url: form.attr("action"), data: form.serialize() })
        .done(function (response) {
          self.respond(response, function () {
            toastr.success(nhMain.getLabel("cap_nhat_thanh_cong"));
            window.location.href = form.data("list");
          });
        })
        .always(function () { button.prop("disabled", false); });
    });
  },
};

$(document).ready(function () {
  nhCourseEnrollment.init();
});
