"use strict";

var nhQuiz = (function () {
  var formEl;
  var validator;

  var initValidation = function () {
    nhMain.validation.url.init();

    validator = formEl.validate({
      ignore: ":hidden",
      rules: {
        name: {
          required: true,
          maxlength: 255,
        },
        link: {
          required: true,
          maxlength: 255,
          url: true,
        },
      },
      messages: {
        name: {
          required: nhMain.getLabel("vui_long_nhap_thong_tin"),
          maxlength: nhMain.getLabel("thong_tin_nhap_qua_dai"),
        },

        link: {
          required: nhMain.getLabel("vui_long_nhap_thong_tin"),
          maxlength: nhMain.getLabel("thong_tin_nhap_qua_dai"),
        },
      },

      errorPlacement: function (error, element) {
        var messageRequired = element.attr("message-required");
        if (
          typeof messageRequired != _UNDEFINED &&
          messageRequired.length > 0
        ) {
          error.text(messageRequired);
        }
        error.addClass("invalid-feedback");

        var group = element.closest(".input-group");
        if (group.length) {
          group.after(error);
        } else if (element.hasClass("select2-hidden-accessible")) {
          element.closest(".form-group").append(error);
        } else {
          element.after(error);
        }
      },

      invalidHandler: function (event, validator) {
        KTUtil.scrollTo(
          validator.errorList[0].element,
          nhMain.validation.offsetScroll
        );
      },
    });
  };

  var initSubmit = function () {
    $(document).on("click", ".btn-save", function (e) {
      e.preventDefault();

      if (validator.form()) {
        var resultScore = nhSeoAnalysis.getScore();
        $("#seo-score").val(resultScore.seoScore);
        $("#keyword-score").val(resultScore.seoKeywordScore);

        // get content tinymce editor
        $("#description").val(tinymce.get("description").getContent());
        $("#content").val(tinymce.get("content").getContent());

        $(`[data-type="editor"]`).each(function() {
          const dataId = $(this).attr("id");
          $(this).val(tinymce.get(dataId).getContent());
        });

        nhMain.initSubmitForm(formEl, $(this));
      }
    });

    $(document).on("click", ".btn-save-draft", function () {
      formEl.find('input[name="draft"]').val(1);
      $("#btn-save").trigger("click");
    });
  };

  var managerItem = {
    init: function () {
      $("#wrap-item-config").sortable();
    },
  };

  return {
    init: function () {
      formEl = $("#main-form");
      initValidation();
      initSubmit();
      managerItem.init();

      nhMain.selectMedia.single.init();
      nhMain.selectMedia.album.init();
      nhMain.selectMedia.video.init({
        input: $("#url_video"),
      });
      nhMain.selectMedia.file.init();

      nhMain.input.touchSpin.init($('input[name="position"]'), {
        prefix: '<i class="la la-sort-amount-desc"></i>',
        max: 9999999999,
        step: 1,
      });

      $(".kt-select-multiple").select2();
      $(".kt-selectpicker").selectpicker();

      nhMain.tagSuggest.init();
      nhMain.tinyMce.simple();
      nhMain.tinyMce.full({
        keyup: function (a) {
          nhSeoAnalysis.getContentWhenKeyUpTinyMCE(a);
        },
      });
      nhSeoAnalysis.init();

      nhMain.mainCategory.init({
        wrapCategory: ["#wrap-category"],
      });

      setTimeout(function () {
        nhMain.scrollToAnchor.init();
      }, 1000);
    },
  };
})();

$(document).ready(function () {
  nhQuiz.init();
});
