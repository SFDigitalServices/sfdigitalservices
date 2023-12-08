$('#ham, #menu-back').click(function(e) {
  e.preventDefault();
  if($('#menu').hasClass('in')) {
    resetMenu();
  } else {
    var overlayHeight = $('body').height() + 'px';
    $('#menu').addClass('in');
    $('#menu').css({'height': overlayHeight });
    $('#nav-overlay').css({'height': overlayHeight, 'display': 'block' });
  }
});

$('#nav-overlay').click(function() {
  resetMenu();
});

$(window).resize(function() {
  var width = $(this).width();
  if(width > 768) {
    resetMenu();
    $('#menu').css({'height':'auto'});
  }
});

function resetMenu() {
  $('#menu').removeClass('in');
  $('#nav-overlay').css({'display':'none'});
  setTimeout(function() {
    $('#menu').css({'height':'auto'});
  }, 300);
}

(function() {
  $('#skip-link').click(function() {
    $(window).scrollTop($('.main').position().top - $('.navbar-brand.logo img').height());
    $('.main').attr('tabindex', '-1');
    $('.main').focus();
  });
  $('#skip-link').on('focus', function() {
    $(this).addClass('skip-link-active');
    var minLeftPos = $('#skip-link').position().left + $('#skip-link').width();
    var logoLeftPos = $('.navbar-brand.logo').position().left;
    if(logoLeftPos < minLeftPos) $('.navbar-brand.logo').css({'margin-left': (parseFloat($('.navbar-brand.logo').css('margin-left').replace('px','')) + $(this).width()) + 'px'});
  });
  $('#skip-link').on('blur', function() {
    $(this).removeClass('skip-link-active');
    $('.navbar-brand.logo').attr('style', '');
  });
})();