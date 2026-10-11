"use strict";

var nhSettingApproved = function () {

    var formApprovedArticle;
    var formApprovedQuiz;
    var formApprovedProduct;

    var initSubmit = function() {
        $(document).on('click', '#btn-save-approved-article', function(e) {
            e.preventDefault();
            nhMain.initSubmitForm(formApprovedArticle, $(this));
        });

        $(document).on('click', '#btn-save-approved-quiz', function(e) {
            e.preventDefault();
            nhMain.initSubmitForm(formApprovedQuiz, $(this));
        });

        $(document).on('click', '#btn-save-approved-product', function(e) {
            e.preventDefault();
            nhMain.initSubmitForm(formApprovedProduct, $(this));
        });
    }

    return {
        init: function() {
            formApprovedArticle = $('#approved-article-form');
            formApprovedQuiz = $('#approved-quiz-form');
            formApprovedProduct = $('#approved-product-form');
            initSubmit();
        }
    };
}();

$(document).ready(function() {
    nhSettingApproved.init();
});