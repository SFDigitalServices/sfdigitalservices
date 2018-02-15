// $('#ham, #menu-back').click(function(e) {
//   e.preventDefault();
//   if($('#menu').hasClass('in')) {
//     $('#menu').removeClass('in');
//     setTimeout(function() {
//       $('#menu').css({'height':'auto'});
//     }, 300);
//   } else {
//     var wHeight = $(window).height() + 'px';
//     $('#menu').addClass('in');
//     $('#menu').css({'height': wHeight });
//     // $('#nav-overlay').css({'height': wHeight, 'display': 'block' });
//   }
// });

// $(window).resize(function() {
//   var width = $(this).width();
//   if(width > 768) {
//     $('#menu').removeClass('in');
//     $('#menu').css({'height':'auto'});
//   }
// });