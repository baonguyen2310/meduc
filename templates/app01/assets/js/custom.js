// pp-login-google
setTimeout(() => {
    const ppLoginGoogle = document.querySelector(".pp-login-google");
    if(ppLoginGoogle) {
        const btnClose = ppLoginGoogle.querySelector(".btn-close");
        if(btnClose) {
            btnClose.addEventListener("click", () => {
                ppLoginGoogle.classList.add("d-none");
            });
        }
    }
}, 1000);
// End pp-login-google

// Fixed Form Order
const divFixed = document.querySelector(".form-quiz--fixed");

if (divFixed) {
    const divWrap = document.querySelector(".form-quiz-detail");

    const divRight = document.querySelector(".form-quiz--right");
    const widthForm = divRight.offsetWidth;

    divFixed.style.cssText = `
    width: ${widthForm}px;
  `;

    window.addEventListener("scroll", function () {
        if (window.scrollY > divWrap.offsetTop) {
            divFixed.classList.add("form-fixed");
        } else {
            divFixed.classList.remove("form-fixed");
        }

        if (window.scrollY > divWrap.offsetHeight + divWrap.offsetTop) {
            divFixed.classList.add("form-end-fixed");
        } else {
            divFixed.classList.remove("form-end-fixed");
        }
    });
}
// End Fixed Form Order

// Contact Fixed
$(document).ready(function() {
    $('.contact-fixed').click(function() {
        $('.contact-fixed__list').toggleClass('show');
        $('.contact-fixed__close').toggleClass('show');
        $('.contact-fixed__button').toggleClass('show');
    });
});
// End Contact Fixed

// Box Show More
$(document).ready(function() {
    $('.button-show-more').click(function() {
        $('.box-show-more').toggleClass('show-all');
        $(this).toggleClass('d-none');
    });
});
// End Box Show More

$(document).ready(function() {
    $("footer").addClass('eduvibe-footer-one edu-footer footer-style-default');
});

var lightboxVideo = GLightbox({
    selector: '.glightbox-video-course',
    closeOnOutsideClick: false
});

var lightboxFeedback = GLightbox({
    selector: '.js-feedback'
});

function setCookie(cname, cvalue, exdays) {
    var d = new Date();
    d.setTime(d.getTime() + (exdays*24*60*60*1000));
    var expires = "expires="+ d.toUTCString();
    document.cookie = cname + "=" + cvalue + "; " + expires;
}

function getCookie(cname) {
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for(var i = 0; i <ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
            return c.substring(name.length,c.length);
        }
    }
    return "";
}

// Affiliate
const queryString = window.location.search;
const urlParams = new URLSearchParams(queryString);
const affiliate = urlParams.get('a');
if(affiliate) {
    setCookie("affiliate", affiliate, 30);
}

const cookieAff = getCookie("affiliate");
if(cookieAff) {
    const inputApply = document.querySelector("#affiliate-code");

    if(inputApply) {
        inputApply.value = cookieAff;
    }
}
// End Affiliate

// $(window).scroll(function(){
//   var sticky = $('.header-fixed'),
//       scroll = $(window).scrollTop();

//   if (scroll >= 80) sticky.addClass('fixed');
//   else sticky.removeClass('fixed');
// });

// clock-quiz
const idClockQuiz = document.querySelectorAll("[data-id-quiz]");
let clockInterval;
if(idClockQuiz.length > 0) {
    idClockQuiz.forEach(item => {
        item.addEventListener("click", function() {
            const idQuiz = item.getAttribute("data-id-quiz");
            const eleClockQuiz = document.querySelector(`[data-clock-quiz='${idQuiz}']`);
            eleClockQuiz.classList.add("active");
            const totalTime = parseInt(eleClockQuiz.getAttribute("data-time"));

            let timer = totalTime*60;
            let minutes, seconds;
            clockInterval = setInterval(function () {
                minutes = parseInt(timer / 60, 10);
                seconds = parseInt(timer % 60, 10);
        
                minutes = minutes < 10 ? "0" + minutes : minutes;
                seconds = seconds < 10 ? "0" + seconds : seconds;
        
                eleClockQuiz.querySelector(".inner-minutes").innerHTML = minutes;
                eleClockQuiz.querySelector(".inner-seconds").innerHTML = seconds;
                eleClockQuiz.setAttribute("data-time-work", totalTime*60 - timer);

                if (--timer < 0) {
                    console.log("Hết giờ");
                    const btnSubmit = document.querySelector(`[btn-submit-quiz='${idQuiz}']`);
                    btnSubmit.click();
                    clearInterval(clockInterval);
                }
            }, 1000);
            
            const formQuiz = document.querySelector(`[form-quiz-id='${idQuiz}']`);
            formQuiz.querySelector("input[name='lesson_name']").value = item.getAttribute("data-lesson-name");
            formQuiz.querySelector("input[name='lesson_code']").value = item.getAttribute("data-lesson-code");
        });
    });
}
// End clock-quiz

// Form Quiz
const elementDataQuizs = document.querySelector("[data-quizs]");
if(elementDataQuizs) {
    setTimeout(() => {
        const dataQuizs = JSON.parse(elementDataQuizs.getAttribute("data-quizs"));
        const dataDesc = elementDataQuizs.getAttribute("data-desc");
        const dataProductId = elementDataQuizs.getAttribute("data-product-id");
        const dataMemberId = elementDataQuizs.getAttribute("data-member-id");
        const classRoomId = elementDataQuizs.getAttribute("data-class-room-id");
        const memberCode = elementDataQuizs.getAttribute("data-member-code");
        
        dataQuizs.forEach((item, index) => {
            const dataIdQuiz = document.querySelector(`[data-id-quiz="${item.id}"]`);
            
            if(dataIdQuiz) {
               let time = 0;
                let questions;
                
                item.QuizsAttribute.forEach(attr => {
                    if (attr.attribute_id == 18) {
                        questions = JSON.parse(attr.value);
                    } else if (attr.attribute_id == 19) {
                        time = attr.value;
                    }
                });
                
                if(questions.length > 0) {
                    const elementDiv = document.createElement("div");
                    
                    let html = `
                        <div data-clock-quiz="${item.id}" class="clock-quiz" data-time="${time}" data-time-work="0">
                            <span class="inner-label">Còn lại</span>
                            <span class="inner-time">
                                <span class="inner-minutes">0</span>p
                                :
                                <span class="inner-seconds">0</span>s
                            </span>
                        </div>
                        
                        <div class="modal fade modal-preview-file" id="modalQuiz${item.id}" tabindex="-1" aria-hidden="true" data-bs-backdrop="static" data-bs-keyboard="false">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title">${item.QuizsContent.name} (Thời gian: ${time} phút)</h5>
                                        <button close-clock-quiz="${item.id}" type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <div class="modal-body bg-logo">
                                        <form form-quiz-id="${item.id}" class="form-quiz">
                                            <div class="container">
                                                <div class="row">
                                                    <div class="col-xl-9 col-lg-9 col-md-9 col-sm-12 col-12 my-15">
                                                        <div class="mb-20 fw-bold color-main">
                                                            ${dataDesc}
                                                        </div>
                                                        
                                                        <input name="class_room_id" value="${classRoomId}" class="d-none" />
                                                        <input name="member_code" value="${memberCode}" class="d-none" />
                                                        <input name="quiz_id" value="${item.id}" class="d-none" />
                                                        <input name="product_id" value="${dataProductId}" class="d-none" />
                                                        <input name="customer_id" value="${dataMemberId}" class="d-none" />
                                                        <input name="lesson_name" value="" class="d-none" />
                                                        <input name="lesson_code" value="" class="d-none" />
                    `;
                    
                    questions.forEach((question, key) => {
                        html += `
                            <div class="form-quiz__item" id="target-${item.id}-${key}">
                                <h5 class="form-quiz__item-title">${question.name_vi}</h5>
                                <div class="form-quiz__item-desc">
                                    ${question.description_vi}
                                </div>
                                <div class="form-quiz__item-ques">
                                    ${question.option_one_vi ? `
                                        <div class="form-check">
                                            <input class="form-check-input ${question.answer_vi == "1" ? 'form-check-input--success' : ''}" type="radio" name="${question.code}" id="question1_${question.code}" value="1">
                                            <label class="form-check-label" for="question1_${question.code}">
                                                ${question.option_one_vi}
                                            </label>
                                        </div>
                                    ` : ``}
                                    ${question.option_two_vi ? `
                                        <div class="form-check">
                                            <input class="form-check-input ${question.answer_vi == "2" ? 'form-check-input--success' : ''}" type="radio" name="${question.code}" id="question2_${question.code}" value="2">
                                            <label class="form-check-label" for="question2_${question.code}">
                                                ${question.option_two_vi}
                                            </label>
                                        </div>
                                    ` : ``}
                                    ${question.option_three_vi ? `
                                        <div class="form-check">
                                            <input class="form-check-input ${question.answer_vi == "3" ? 'form-check-input--success' : ''}" type="radio" name="${question.code}" id="question3_${question.code}" value="3">
                                            <label class="form-check-label" for="question3_${question.code}">
                                                ${question.option_three_vi}
                                            </label>
                                        </div>
                                    ` : ``}
                                    ${question.option_four_vi ? `
                                        <div class="form-check">
                                            <input class="form-check-input ${question.answer_vi == "4" ? 'form-check-input--success' : ''}" type="radio" name="${question.code}" id="question4_${question.code}" value="4">
                                            <label class="form-check-label" for="question4_${question.code}">
                                                ${question.option_four_vi}
                                            </label>
                                        </div>
                                    ` : ``}
                                    ${question.option_five_vi ? `
                                        <div class="form-check">
                                            <input class="form-check-input ${question.answer_vi == "5" ? 'form-check-input--success' : ''}" type="radio" name="${question.code}" id="question5_${question.code}" value="5">
                                            <label class="form-check-label" for="question5_${question.code}">
                                                ${question.option_five_vi}
                                            </label>
                                        </div>
                                    ` : ``}
                                </div>
                                ${question.answer_detail_vi ? `
                                    <div class="form-quiz__answer">
                                        <h5>Đáp án chi tiết:</h5>
                                        <div class="form-quiz__answer-detail">
                                            ${question.answer_detail_vi}
                                        </div>
                                    </div>
                                ` : ``}
                            </div>
                        `;
                    });
                    
                    html += `
                                                        <div class="mt-40">
                                                            <button class="edu-btn btn-submit-quiz" btn-submit-quiz="${item.id}">Nộp bài</button>
                                                        </div>
                                                        
                                                        <div class="form-quiz__result--modal">
                                                            <div class="form-quiz__result">
                                                                <h5 class="inner-head">Kết quả:</h5>
                                                                <div class="row">
                                                                    <div class="col-xl-3 col-lg-3 col-md-6 col-sm-6 col-12 my-10">
                                                                        <p>Tổng số câu: <span class="inner-total">0</span></p>
                                                                    </div>
                                                                    <div class="col-xl-3 col-lg-3 col-md-6 col-sm-6 col-12 my-10">
                                                                        <p>Số câu đúng: <span class="inner-correct">0</span></p>
                                                                    </div>
                                                                    <div class="col-xl-3 col-lg-3 col-md-6 col-sm-6 col-12 my-10">
                                                                        <p>Số câu sai: <span class="inner-false">0</span></p>
                                                                    </div>
                                                                    <div class="col-xl-3 col-lg-3 col-md-6 col-sm-6 col-12 my-10">
                                                                        <p>Tỷ lệ đúng: <span class="inner-ratio"></span></p>
                                                                    </div>
                                                                    <div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 my-10">
                                                                        <p><span class="inner-result"></span></p>
                                                                    </div>
                                                                </div>
                                                                <div class="mt-30">
                                                                    <span class="edu-btn btn-reset-quiz" btn-reset-quiz="${item.id}">Làm lại</span>
                                                                    <span class="edu-btn btn-reload">Xem lại bài học</span>
                                                                    <span class="edu-btn btn-result">Đáp án chi tiết</span>
                                                                    <span class="edu-btn btn-continue">Học tiếp</span>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="col-xl-3 col-lg-3 col-md-3 col-sm-12 col-12 my-15">
                                                        <div class="form-quiz__result-toc">
                                                            <div class="inner-box">
                                                                <div class="inner-head">
                                                                    <div class="inner-title">
                                                                        Bấm vào câu đã làm
                                                                    </div>
                                                                    <div class="inner-desc">
                                                                        để xem lại đáp án + lời giải chi tiết
                                                                    </div>
                                                                </div>
                                                                <div class="inner-wrap">
                    `;
                    
                    questions.forEach((question, key) => {
                        html += `
                            <a href="#target-${item.id}-${key}">
                                ${key + 1}
                            </a>
                        `;
                    });
                    
                    html += `
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                    `;
                    
                    elementDiv.innerHTML = html;
                    
                    elementDataQuizs.appendChild(elementDiv);
                    
                    const btnCloseQuiz = elementDiv.querySelector("[close-clock-quiz]");
                    if(btnCloseQuiz) {
                        btnCloseQuiz.addEventListener("click", function() {
                            location.reload();
                        });
                    }
                }
            }
        });
    }, 1000);
}


setTimeout(() => {
    const formsQuiz = document.querySelectorAll("[form-quiz-id]");
    if(formsQuiz.length > 0) {
        formsQuiz.forEach(function(formQuiz) {
            formQuiz.addEventListener('submit', function(e) {
                e.preventDefault();
                
                // List Answer
                const listAnswer = e.target.querySelectorAll(".form-check-input:checked");
                const answers = [...listAnswer].map(item => {
                    return {
                        code: item.name,
                        answer: item.value
                    };
                });
                
                const class_room_id = e.target.class_room_id.value;
                const member_code = e.target.member_code.value;
                const quiz_id = e.target.quiz_id.value;
                const product_id = e.target.product_id.value;
                const customer_id = e.target.customer_id.value;
                const lesson_name = e.target.lesson_name.value;
                const lesson_code = e.target.lesson_code.value;
                
                const total_time = document.querySelector(".clock-quiz.active").getAttribute("data-time-work");
                
                // UI
                const totalQuestion = e.target.querySelectorAll(".form-quiz__item").length;
                const totalAnswerCorrect = e.target.querySelectorAll(".form-check-input--success:checked").length;
                if(totalAnswerCorrect/totalQuestion >= 0) { // Không cần trả lời đúng, nếu 0.2 thì phải đúng 20%
                    e.target.classList.add("form-quiz--success");
                    e.target.classList.remove("form-quiz--false");
                    // e.target.querySelector(".form-quiz__result .inner-result").innerHTML = "Chúc mừng bạn đã làm đúng >= 20%, bạn đã vượt qua bài kiểm tra.";
                } else {
                    e.target.classList.add("form-quiz--false");
                    e.target.classList.remove("form-quiz--success");
                    // e.target.querySelector(".form-quiz__result .inner-result").innerHTML = "Tỷ lệ đúng của bạn dưới 20%, vui lòng làm lại bài kiểm tra để xem được đáp án.";
                }
                
                e.target.querySelector(".form-quiz__result .inner-total").innerHTML = totalQuestion;
                e.target.querySelector(".form-quiz__result .inner-correct").innerHTML = totalAnswerCorrect;
                e.target.querySelector(".form-quiz__result .inner-false").innerHTML = totalQuestion - totalAnswerCorrect;
                e.target.querySelector(".form-quiz__result .inner-ratio").innerHTML = (totalAnswerCorrect/totalQuestion*100).toFixed(2) + "%";
                
                e.target.querySelector(".btn-reset-quiz").addEventListener("click", function() {
                    e.target.classList.remove("form-quiz--success");
                    e.target.classList.remove("form-quiz--false");
                    e.target.querySelectorAll(".form-check-input:checked").forEach(function(itemInput) {
                        itemInput.checked = false;
                    });
                    
                    const idQuiz = this.getAttribute("btn-reset-quiz");
                    const eleClockQuiz = document.querySelector(`[data-clock-quiz='${idQuiz}']`);
                    
                    const totalTime = parseInt(eleClockQuiz.getAttribute("data-time"));
    
                    let timer = totalTime*60;
                    let minutes, seconds;
                    clockInterval = setInterval(function () {
                        minutes = parseInt(timer / 60, 10);
                        seconds = parseInt(timer % 60, 10);
                
                        minutes = minutes < 10 ? "0" + minutes : minutes;
                        seconds = seconds < 10 ? "0" + seconds : seconds;
                
                        eleClockQuiz.querySelector(".inner-minutes").innerHTML = minutes;
                        eleClockQuiz.querySelector(".inner-seconds").innerHTML = seconds;
                        eleClockQuiz.setAttribute("data-time-work", totalTime*60 - timer);
        
                        if (--timer < 0) {
                            console.log("Hết giờ");
                            const btnSubmit = document.querySelector(`[btn-submit-quiz='${idQuiz}']`);
                            btnSubmit.click();
                            clearInterval(clockInterval);
                        }
                    }, 1000);
                });
                
                if(customer_id) {
                    const data = {
                        class_room_id: parseInt(class_room_id),
                        member_code: member_code,
                        quiz_id: parseInt(quiz_id),
                        product_id: parseInt(product_id),
        				customer_id: parseInt(customer_id),
        				lesson_name: lesson_name,
        				lesson_code: lesson_code,
        				answers: JSON.stringify(answers),
        				answer_total: totalQuestion,
        				answer_correct: totalAnswerCorrect,
        				answer_wrong: totalQuestion - totalAnswerCorrect,
        				answer_correct_percent: (totalAnswerCorrect/totalQuestion*100).toFixed(2),
        				total_time: parseInt(total_time)
        			};
        			
                    nhMain.callAjax({
                		async: true,
            			url: '/quizs-answer/add',
            			data: data,
            		}).done(function(response) {
            			console.log(response);
            		});
                }
        		
        		clearInterval(clockInterval);
                
                // Reload
                e.target.querySelector(".btn-continue").addEventListener("click", function() {
                    location.reload();
                });
                
                // Reload
                e.target.querySelector(".btn-reload").addEventListener("click", function() {
                    location.reload();
                });
                
                // btn-result
                e.target.querySelector(".btn-result").addEventListener("click", function() {
                    e.target.classList.add("form-quiz--show-result");
                });
                
                e.target.querySelectorAll(".form-quiz__item").forEach((item, index) => {
                    const inputChecked = item.querySelector(".form-check-input:checked");
                    if(inputChecked.classList.contains("form-check-input--success")) {
                        e.target.querySelector(`.form-quiz__result-toc .inner-wrap a:nth-child(${index+1})`).classList.add("true");
                    } else {
                        e.target.querySelector(`.form-quiz__result-toc .inner-wrap a:nth-child(${index+1})`).classList.add("false");
                    }
                })
            });
        });
    }
}, 5000);
// End Form Quiz

// Show Button Video
const buttonVideo = document.querySelector(".accordion-item .inner-file .glightbox-video-course.d-none");
if(buttonVideo) {
    buttonVideo.classList.remove("d-none");
}

const buttonQuiz = document.querySelector(".accordion-item .inner-head .btn-quiz.d-none");
if(buttonQuiz) {
    buttonQuiz.classList.remove("d-none");
}

const buttonFiles = document.querySelector(".accordion-item .inner-files.d-none");
if(buttonFiles) {
    buttonFiles.classList.remove("d-none");
}
// End Show Button Video

// Btn Trial
const showModalTrial = () => {
    const btnClose = document.querySelector("#glightbox-body button.gclose.gbtn");
    btnClose.addEventListener("click", function() {
        $('#modalTrial').modal('show');
    });
}

const btnsTrial = document.querySelectorAll("[btn-trial]");
if(btnsTrial.length > 0) {
    btnsTrial.forEach(item => {
        item.addEventListener("click", showModalTrial);
    });
}
// End Btn Trial

// form-quiz-detail
const formQuizDetail = document.querySelector(".form-quiz-detail");
if(formQuizDetail) {
    // clock-quiz
    const clockQuizDetail = document.querySelector(".clock-quiz");
    const totalTimeDetail = parseInt(clockQuizDetail.getAttribute("data-time"));
    
    let timerDetail = totalTimeDetail*60;
    let minutes, seconds, clockIntervalDetail;
    clockIntervalDetail = setInterval(function () {
        minutes = parseInt(timerDetail / 60, 10);
        seconds = parseInt(timerDetail % 60, 10);

        minutes = minutes < 10 ? "0" + minutes : minutes;
        seconds = seconds < 10 ? "0" + seconds : seconds;

        clockQuizDetail.querySelector(".inner-minutes").innerHTML = minutes;
        clockQuizDetail.querySelector(".inner-seconds").innerHTML = seconds;
        clockQuizDetail.setAttribute("data-time-work", totalTimeDetail*60 - timerDetail);

        if (--timerDetail < 0) {
            console.log("Hết giờ");
            const btnSubmit = document.querySelector(`.btn-submit-quiz`);
            btnSubmit.click();
            clearInterval(clockIntervalDetail);
        }
    }, 1000);
    // End clock-quiz
    
    
    formQuizDetail.addEventListener('submit', function(e) {
        e.preventDefault();
        
        // List Answer
        const listAnswer = e.target.querySelectorAll(".form-check-input:checked");
        const answers = [...listAnswer].map(item => {
            return {
                code: item.name,
                answer: item.value
            };
        });
        
        const quiz_id = e.target[0].value;
        const customer_id = e.target[1].value;
        const total_time = document.querySelector(".clock-quiz").getAttribute("data-time-work");
        
        // UI
        const totalQuestion = e.target.querySelectorAll(".form-quiz__item").length;
        const totalAnswerCorrect = e.target.querySelectorAll(".form-check-input--success:checked").length;
        
        e.target.classList.add("form-quiz--success");

        e.target.querySelector(".form-quiz__result .inner-total").innerHTML = totalQuestion;
        e.target.querySelector(".form-quiz__result .inner-correct").innerHTML = totalAnswerCorrect;
        e.target.querySelector(".form-quiz__result .inner-false").innerHTML = totalQuestion - totalAnswerCorrect;
        e.target.querySelector(".form-quiz__result .inner-ratio").innerHTML = (totalAnswerCorrect/totalQuestion*100).toFixed(2) + "%";
        
    //     if(customer_id) {
    //         nhMain.callAjax({
    //     		async: true,
    // 			url: '/quizs-answer/add',
    // 			data: {
    // 				customer_id: customer_id,
    // 				quiz_id: quiz_id,
    // 				answers: JSON.stringify(answers),
    // 				answer_total: totalQuestion,
    // 				answer_correct: totalAnswerCorrect,
    // 				answer_wrong: totalQuestion - totalAnswerCorrect,
    // 				answer_correct_percent: (totalAnswerCorrect/totalQuestion*100).toFixed(2),
    // 				total_time: total_time
    // 			},
    // 		}).done(function(response) {
    // 			console.log(response);
    // 		});
    //     } else {
    //     }
		
		clearInterval(clockIntervalDetail);
		
		// Reload
        e.target.querySelector(".btn-reset-quiz").addEventListener("click", function() {
            location.reload();
        });
        
        // btn-result
        e.target.querySelector(".btn-result").addEventListener("click", function() {
            e.target.classList.add("form-quiz--show-result");
        });
        
        e.target.querySelectorAll(".form-quiz__item").forEach((item, index) => {
            const inputChecked = item.querySelector(".form-check-input:checked");
            if(inputChecked.classList.contains("form-check-input--success")) {
                e.target.querySelector(`.form-quiz__result-toc .inner-wrap a:nth-child(${index+1})`).classList.add("true");
            } else {
                e.target.querySelector(`.form-quiz__result-toc .inner-wrap a:nth-child(${index+1})`).classList.add("false");
            }
        })
        
        // btn-continue
        e.target.querySelector(".btn-continue").addEventListener("click", function() {
            window.history.back();
        });
        
    });
}
// End form-quiz-detail

// data-course-license
const dataCourseLicense = document.querySelector("[data-course-license]");
if(dataCourseLicense) {
    const totalCourseLicense = document.querySelectorAll("[data-course-license] [nh-product]").length;
    localStorage.setItem("totalCourseLicense", totalCourseLicense);
}

const eleTotalCourseLicense = document.querySelector("[total-course-license]");
if(eleTotalCourseLicense) {
    let total = localStorage.getItem("totalCourseLicense") || "0";
    eleTotalCourseLicense.querySelector(".inner-course-license").innerHTML = total;
}
// End data-course-license

// btn-logout
$(document).ready(function() {
    const btnLogout = document.querySelectorAll("[btn-logout]");
    if(btnLogout) {
        btnLogout.forEach(item => {
            item.addEventListener("click", function() {
                localStorage.removeItem("totalCourseLicense");
            });
        });
    }
});
// End btn-logout

// header-fixed
const headerHome = document.querySelector("body.home");
if(headerHome) {
    document.querySelector(".header-main").classList.add("header-fixed");
}
// End header-fixed


// pdf-viewer
const pdfViewer = document.querySelectorAll("[pdf-viewer]");
if(pdfViewer) {
    setTimeout(() => {
        pdfViewer.forEach(item => {
            const file = item.getAttribute("data-file");
            WebViewer({
                path: 'https://meduc.vn/templates/app01/assets/lib/libpdf',
                licenseKey: 'up8xA4TjrpyO4xbpqZ2y',
                initialDoc: file,
                disabledElements: [
                    'viewControlsButton',
                    'viewControlsOverlay',
                    'searchButton',
                    'panToolButton',
                    'selectToolButton',
                    'toolsButton',
                    'printModal'
                ]
              }, item)
              .then(instance => {
                instance.UI.setLanguage('vi');
                instance.UI.disableElements(['ribbons']);
                instance.UI.disableElements(['toggleNotesButton']);
                
                instance.UI.disableElements(['menuButton']);
    
                  instance.UI.setHeaderItems((header) => {
                    header.getHeader('default').push({
                      img: "icon-header-full-screen",
                      index: -1,
                      type: "actionButton",
                      element: 'fullScreenButton',
                      onClick: () => {
                        instance.UI.toggleFullScreen()
                      }
                    });
                  });
            });
        })
    }, 2500);
}
// End pdf-viewer

// Fixed Form Order
const divFixedCourse = document.querySelector(".product-detail-head__fixed");

if (divFixedCourse) {
    const divWrap = document.querySelector(".product-detail-main__wrap");

    const divRight = document.querySelector(".product-detail-main__right");
    const widthForm = divRight.offsetWidth;

    divFixedCourse.style.cssText = `
    width: ${widthForm}px;
  `;

    window.addEventListener("scroll", function () {
        if (window.scrollY > divWrap.offsetTop) {
            divFixedCourse.classList.add("form-fixed");
        } else {
            divFixedCourse.classList.remove("form-fixed");
        }

        if (window.scrollY > divWrap.offsetHeight + divWrap.offsetTop + 100 - screen.height) {
            divFixedCourse.classList.add("form-end-fixed");
        } else {
            divFixedCourse.classList.remove("form-end-fixed");
        }
    });
}
// End Fixed Form Order

// Chặn download Cốc Cốc
window.addEventListener("load", (event) => {
    const intervalDownload = setInterval(boxDownloadCocCoc, 1000);
    
    function boxDownloadCocCoc() {
        const boxDownload = document.querySelector("body ~ div");
        if(boxDownload) {
            boxDownload.remove();
            clearInterval(intervalDownload);
        }
    }
});
// Hết Chặn download Cốc Cốc

const buttonsViewFile = document.querySelectorAll("[btn-view-file]");
if(buttonsViewFile.length > 0) {
    const pdf_container = document.getElementById("pdf_container");
    buttonsViewFile.forEach((button) => {
        button.addEventListener("click", () => {
            pdf_container.innerHTML = "";
            const newElement = document.createElement("div");
            newElement.classList.add("inner-box");
            pdf_container.appendChild(newElement);
            const urlFile = button.getAttribute("data-file");
            
            WebViewer({
                path: 'https://meduc.vn/templates/app01/assets/lib/libpdf',
                licenseKey: 'up8xA4TjrpyO4xbpqZ2y',
                initialDoc: urlFile,
                disabledElements: [
                    'viewControlsButton',
                    'viewControlsOverlay',
                    'searchButton',
                    'panToolButton',
                    'selectToolButton',
                    'toolsButton',
                    'printModal'
                ]
              }, newElement)
              .then(instance => {
                instance.UI.setLanguage('vi');
                instance.UI.disableElements(['ribbons']);
                instance.UI.disableElements(['toggleNotesButton']);
                
                instance.UI.disableElements(['menuButton']);
    
                  instance.UI.setHeaderItems((header) => {
                    header.getHeader('default').push({
                      img: "icon-header-full-screen",
                      index: -1,
                      type: "actionButton",
                      element: 'fullScreenButton',
                      onClick: () => {
                        instance.UI.toggleFullScreen()
                      }
                    });
                  });
            });
        });
    });
}
// End btn-view-file

// Fixed Order
const productDetailOrder = document.querySelector(".product-detail-order .inner-box");

if (productDetailOrder) {
    const divWrap = document.querySelector(".product-detail-book");

    const divRight = document.querySelector(".product-detail-order");
    const widthForm = divRight.offsetWidth;

    productDetailOrder.style.cssText = `
    width: ${widthForm}px;
  `;

    window.addEventListener("scroll", function () {
        if (window.scrollY > divWrap.offsetTop) {
            productDetailOrder.classList.add("form-fixed");
        } else {
            productDetailOrder.classList.remove("form-fixed");
        }

        if (window.scrollY > divWrap.offsetHeight + divWrap.offsetTop + 300 - screen.height) {
            productDetailOrder.classList.add("form-end-fixed");
        } else {
            productDetailOrder.classList.remove("form-end-fixed");
        }
    });
}
// End Fixed Order

// Scroll Table Rank
const scrollTable = document.querySelector("[scroll-table]");
if(scrollTable) {
    scrollTable.addEventListener('wheel', function(event) {
        // Ngăn sự kiện cuộn mặc định của trình duyệt
        event.preventDefault();

        // Lấy vị trí scroll ngang hiện tại của bảng
        let scrollLeft = this.scrollLeft || document.documentElement.scrollLeft;

        // Tính toán delta của sự kiện cuộn chuột
        let delta = event.deltaX !== 0 ? event.deltaX : event.deltaY;

        // Nếu delta dương (cuộn sang phải) và scrollLeft đã cuộn đến cực đại bên phải
        if (delta > 0 && this.clientWidth + this.scrollLeft >= this.scrollWidth) {
            return; // Ngăn không cho cuộn ngang tiếp tục khi cuộn đến cực đại
        }
        // Nếu delta âm (cuộn sang trái) và scrollLeft đã cuộn đến cực đại bên trái
        else if (delta < 0 && this.scrollLeft === 0) {
            return; // Ngăn không cho cuộn ngang tiếp tục khi cuộn đến cực đại
        }

        // Điều chỉnh vị trí scroll ngang dựa vào delta của sự kiện cuộn chuột
        this.scrollLeft += delta;
    });
}
// End Scroll Table Rank

// btn-add-cart-2
const btnAddCart2 = document.querySelector("[btn-add-cart-2]");
if(btnAddCart2) {
    btnAddCart2.addEventListener("click", () => {
        const btnActionAddCart = document.querySelector("[dc-btn-action='add-cart']");
        if(btnActionAddCart) {
            btnActionAddCart.click();
        }
    })
}
// End btn-add-cart-2

// button-copy-link
const buttonCopyLink = document.querySelector("[button-copy-link]");
if(buttonCopyLink) {
    buttonCopyLink.addEventListener("click", () => {
        const link = buttonCopyLink.getAttribute("data-link");
        navigator.clipboard.writeText(link)
            .then(() => {
                nhMain.showAlert(_SUCCESS, "Đã copy link affiliate!");
            });
    })
}
// End button-copy-link

// box-couse-in-blog
document.addEventListener("DOMContentLoaded", () => {
  const article = document.querySelector(".article-detail");
  if (!article) return; // Nếu không có khối article-detail thì dừng

  const source = document.querySelector(".box-couse-in-blog");
  if (!source) return; // Nếu không có khối mẫu thì dừng

  // Quét tất cả phần tử bên trong article-detail
  const elements = article.querySelectorAll("*");

  elements.forEach(el => {
    // Kiểm tra nếu nội dung của thẻ đúng bằng %%danhsachkhoahoc%%
    if (el.textContent.trim() === "%%danhsachkhoahoc%%") {
      const clone = source.cloneNode(true);
      clone.style.display = "block";
      el.replaceWith(clone); // Thay toàn bộ thẻ bằng khối clone
    }
  });
});
// End box-couse-in-blog

$(document).ready(function() {
    $('#categoryTopicButton').click(function() {
        $('#categoryTopic').addClass('show');
        $('#categoryTopicOverlay').addClass('show');
    });
    $('#categoryTopicOverlay').click(function() {
        $('#categoryTopic').removeClass('show');
        $('#categoryTopicOverlay').removeClass('show');
    });
});

$(document).ready(function() {
    $('#articleNext').click(function() {
        const liNext = $('#categoryTopic a.active').parent().next().attr("data-url");
        if(liNext) {
            location.href = liNext;
        } else {
            const liNext2 = $('#categoryTopic a.active').parent().parent().parent().next().children("ul").children("li:first-child").attr("data-url");
            if(liNext2) {
                location.href = liNext2;
            }
        }
    });
    
    $('#articlePrev').click(function() {
        const liPrev = $('#categoryTopic a.active').parent().prev().attr("data-url");
        if(liPrev) {
            location.href = liPrev;
        } else {
            const liPrev2 = $('#categoryTopic a.active').parent().parent().parent().prev().children("ul").children("li:last-child").attr("data-url");
            if(liPrev2) {
                location.href = liPrev2;
            }
        }
    });
});

window.addEventListener("DOMContentLoaded", () => {
  // Chỉ chạy nếu màn hình >= 992px
  if (window.innerWidth >= 992) {
    const activeItem = document.querySelector(".category-topic .inner-title-2.active");
    if (activeItem) {
      activeItem.scrollIntoView({
        behavior: "smooth", // Cuộn mượt
        block: "center"     // Đưa phần tử vào giữa khối cuộn
      });
    }
  }
});

// Fixed category-topic
const categoryTopic = document.querySelector(".category-topic");
if (categoryTopic) {
    const divWrap = categoryTopic.closest(".row");

    const divLeft = divWrap.querySelector(".col-md-3");
    const widthForm = divLeft.offsetWidth - 15;

    categoryTopic.style.cssText = `
    width: ${widthForm}px;
  `;

    window.addEventListener("scroll", function () {
        if (window.scrollY > divWrap.offsetTop) {
            categoryTopic.classList.add("form-fixed");
        } else {
            categoryTopic.classList.remove("form-fixed");
        }

        if (window.scrollY > divWrap.offsetHeight + divWrap.offsetTop + 100 - screen.height) {
            categoryTopic.classList.add("form-end-fixed");
        } else {
            categoryTopic.classList.remove("form-end-fixed");
        }
    });
}
// End Fixed category-topic

document.addEventListener("DOMContentLoaded", () => {
  const box = document.querySelector(".js-show-more");

  if (!box) return;

  const content = box.querySelector(".show-more__content");
  const button = box.querySelector(".show-more__button");

  button.addEventListener("click", () => {
    const isActive = box.classList.toggle("is-active");
    content.style.maxHeight = content.scrollHeight + "px";
    button.style.display = "none";

    // if (isActive) {
    //   // Mở rộng: đặt max-height = chiều cao thật
    //   content.style.maxHeight = content.scrollHeight + "px";
    //   button.textContent = "Thu gọn";
    // } else {
    //   // Thu gọn
    //   content.style.maxHeight = "200px";
    //   button.textContent = "Xem thêm";
    // }
  });
});
