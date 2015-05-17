$(document).ready(function(){
  $('.wrapper').on('click', '.submit-button', function(event) {
    event.preventDefault();

    var data = $('.question').serialize();
    var url = $(this).parent().attr('action');
    var req = $.ajax({
      url: url,
      method: "post",
      data: data,
      dataType: "json",
      error: function(response){
        er = response;
      },
      success: function(response){
        sr = response;
      }
    });
  })


  var data=(SCORES);
  var title=(TITLE);

  $(function () {
    $('#container').highcharts({
      chart: {
          type: 'line'
      },
      title: {
          text: 'Recog Results'
      },
      xAxis: {
          title: {
            text: "Test Number"
          },
          allowDecimals: false
      },

      yAxis: {
          title: {
              text: 'Score'
          }
      },
      series: [{
          name: title,
          data: data,
          pointStart: 1,
          pointInterval: 1
      }]
    })
  })


})
