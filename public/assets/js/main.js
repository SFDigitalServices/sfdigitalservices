$('#ham, #menu-back').click(function() {
  if($('#menu').hasClass('in')) {
    $('#menu').removeClass('in');
    setTimeout(function() {
      $('#menu').css({'height':'auto'});
    }, 300);
  } else {
    $('#menu').addClass('in');
    $('#menu').css({'height':$(window).height() + 'px'});
  }
  // $('#menu').toggleClass('in');
  // $('#menu.in').height($(window).height());
});

$(window).resize(function() {
  var width = $(this).width();
  if(width > 768) {
    $('#menu').removeClass('in');
    $('#menu').css({'height':'auto'});
  }
});