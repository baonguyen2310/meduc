if($('#time_sale_all_product').length > 0) {
    var time_new = $('#time_sale_all_product').attr('nh-time-end');
    var countDownDateTimeSale = new Date(time_new).getTime();
    
    // cập nhập thời gian sau mỗi 1 giây
    var x = setInterval(function() {
    // 	Lấy thời gian hiện tại
    	var now = new Date().getTime();
    
    // 	Lấy số thời gian chênh lệch
    	var distance = countDownDateTimeSale - now;
    
    // 	Tính toán số ngày, giờ, phút, giây từ thời gian chênh lệch
    	var days = Math.floor(distance / (1000 * 60 * 60 * 24));
    	var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    	var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
    	var seconds = Math.floor((distance % (1000 * 60)) / 1000);
    
    // 	HIển thị chuỗi thời gian trong thẻ p
    	document.getElementById("time_sale_all_product").innerHTML = "<p class=\"hour\">" + days + " ngày<\/p> <p class=\"hour\">" + hours + " giờ<\/p> <p class=\"hour\">" + minutes + " phút<\/p> <p class=\"hour\">" + seconds + " giây<\/p>";
    	
    // 	Nếu thời gian kết thúc, hiển thị chuỗi thông báo
    	if (distance < 0) {
    	  clearInterval(x);
    	  document.getElementById("time_sale_all_product").innerHTML = "Thời gian khuyến mãi đã kết thúc";
    	}
    }, 1000);
}

var nhFilter = {
    init: function(){
		var self = this;

		if(typeof(nhFilter.isMobile) != _UNDEFINED && !nhFilter.isMobile){
			self.stickyMenu();
		}
		
		self.mainFilter.init();

		// active menu use nh-toggle
		if($('[nh-menu] a[href="'+ nhMain.pathname +'"]').length > 0 && !nhMain.isMobile){
			$('[nh-menu] a[href="'+ nhMain.pathname +'"]').each(function( index ){

				$(this).addClass('active');

				var toggleElement = $(this).parents('[nh-toggle-element]');
				if(toggleElement.length == 0) return;

				toggleElement.each(function(index){
					$(this).addClass('active').css({'display': 'block'});

					var key = $(this).attr('nh-toggle-element');
					$('[nh-toggle="' + key + '"]').addClass('open');
				});
			});
		}
	},
	mainFilter: {
		menuObject: null,
		init: function() {
			var self = this;
			
			self.menuObject = $('[nh-filter="sidebar"]');

			if(self.menuObject == null || self.menuObject == _UNDEFINED || self.menuObject.length == 0){
				return false
			};

			$(document).on('click', '[nh-filter="btn-open"]', function(e) {
				e.preventDefault();
				self.toggleMenu(!self.menuObject.hasClass('open'));
			});

			$(document).on('click', '[nh-filter="btn-close"]', function(e) {
				e.preventDefault();
				self.toggleMenu(false);
			});
			
			$(document).on('click', '.back-filter', function(e) {
				if(($(e.target).is('[nh-filter="close"]') || $(e.target).is('.back-filter.open')) && self.menuObject.hasClass('open')){
					self.toggleMenu(false);
				}
			});
		},
		toggleMenu: function(open = true){
			var self = this;

			self.menuObject.toggleClass('open', open);
			$('.back-filter').toggleClass('open', open);
		},
	}
	
}

$(document).ready(function() {
	nhFilter.init();
});

$(".btn-view-all").click(function() {
    $('.product-content').toggleClass('transform-active');
    if(!$('.product-content').hasClass('transform-active')){
        $('html, body').animate({
            scrollTop: $('#prd-content').offset().top - 85
        }, 'slow');
    }
    
});

$(document).ready(function(){
    $(window).scroll(function() {    
       var scroll = $(window).scrollTop();
       if (scroll > 100) {
            $(".search-mobile").addClass("fix-search");
       } else {
        	$(".search-mobile").removeClass("fix-search");
       }
    });
});

// Contact Fixed
$(document).ready(function() {
    $('.contact-fixed').click(function() {
        $('.contact-fixed__list').toggleClass('show');
        $('.contact-fixed__close').toggleClass('show');
        $('.contact-fixed__button').toggleClass('show');
    });
});
// End Contact Fixed