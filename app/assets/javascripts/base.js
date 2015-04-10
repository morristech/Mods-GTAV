function doResize() {
	if ($(window).width() <= 1160) {  
		$('.right_sidebar_preview, .close_sidebar').on('click', function(e) {
			e.preventDefault();
			toggleSidebar();
		});
	}
}

function toggleSidebar() {
	var preview = $('.right_sidebar_preview');
	if (preview.hasClass('showsidebarpreview')) {
		localStorage.setItem('sidebar', false);
	} else {
		localStorage.setItem('sidebar', true);
	}
	toggleSidebarClasses();
}

function toggleSidebarClasses() {
	$('.right_sidebar_preview').toggleClass('showsidebarpreview');
	$('.right_sidebar').toggleClass('showsidebar');
	if ($('.close_sidebar').css('display') === 'none') {
		$('.close_sidebar').css('display', 'block');
	} else {
		$('.close_sidebar').css('display', 'none');
	}
}

function handleSidebarLoad() {
	var val = localStorage.getItem('sidebar');
	if (val && val === "true") {
		toggleSidebarClasses();
	}
}

function humanFileSize(bytes, si) {
	var thresh = si ? 1000 : 1024;
	if(bytes < thresh) return bytes + ' B';
	var units = si ? ['kB','MB','GB','TB','PB','EB','ZB','YB'] : ['KiB','MiB','GiB','TiB','PiB','EiB','ZiB','YiB'];
	var u = -1;
	do {
		bytes /= thresh;
		++u;
	} while(bytes >= thresh);
	return bytes.toFixed(1)+' '+units[u];
}

$(document).ready(function() {
	$('.submissiondate').hide();
	$('.likecounter').hide();

	$(".modthumbnailwrap").on({
		mouseenter: function () {
			$('.likecounter', this).stop().fadeIn(200);
			$('.submissiondate', this).stop().fadeIn(200);
		},
		mouseleave: function () {
			$('.likecounter', this).fadeOut(20);
			$('.submissiondate', this).stop().fadeOut(100);
		}
	});

	$(".likecounter").on({
		mouseenter: function () {
			$(this).stop().animate({background: 'transparent'}, 'fast');
			$(this).stop().animateAuto("width", 100);
		},
		mouseleave: function () {
			$(this).stop().animate({width: '40px'}, 'fast');
		}
	});

	$('.registerbutton').on('click', function() {
		$('.signinwrap').hide();
		$('.resetpasswordwrap').hide();
		$('.registerwrap').fadeIn(200);
		$('.registerwrap #user_email').focus();
	});
	$('.signinlink').on('click', function() {
		$('.registerwrap').hide();
		$('.resetpasswordwrap').hide();
		$('.signinwrap').fadeIn(200);
		$('.signinwrap #user_login').focus();
	});
	$('.forgotlink').on('click', function() {
		$('.signinwrap').hide();
		$('.registerwrap').hide();
		$('.resetpasswordwrap').fadeIn(200);
		$('.resetpasswordwrap #user_email').focus();
	});
	$('.tooltip').tooltipster({
		theme: 'tooltipster-light'
	});
	function removeAlert() {
		$('.alert').fadeOut("slow", function() {
			this.remove();
		});
	};

	$('.close-alert').click(function(e) {
		e.preventDefault();
		removeAlert();
	});

	if ($('.close-alert').length) {
		setTimeout(function() {
			removeAlert();
		}, 10000)
	};

	doResize();
	$(window).on('resize', doResize);
	if ($(window).width() <= 1160) { 
		handleSidebarLoad();  
	}
});