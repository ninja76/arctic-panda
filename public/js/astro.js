function draw_map(){
       var spots ;
       var zoom = $("#slider").val() /100;
       var width = $("#mapdiv").width();
       // Set map height based on the width
       $("#mapdiv").height(width-200);
       var height = $("#mapdiv").height();
       // Override width and height with static values
       width = 1200
       height = 1200
       var mapwidth = parseFloat(width);
       var mapheight = parseFloat(height);
       var ra = $("#ra").val();
       var dec = $("#dec").val();
       var isgrid = 1;
       var isclines = 0;
       var maglimit = $('#magslider').val();
       var zoom = $('#zoomslider').val() / 100;
       var xoffset = mapwidth - width;
       var yoffset = mapheight - height;
       if ( $('#showgrid').is(":checked")) {
         isgrid = "1";
         console.log("Show grid is checked");           
       } else { isgrid = "0"; }
       if ( $('#constlines').is(":checked")) {
         isclines = "1";
         console.log("Show grid is checked");
       } else { isclines = "0"; }
       if ( $('#showboundry').is(":checked")) {
         isboundry = "1";
       } else { isboundry = "0"; }
       if ( $('#showmilkyway').is(":checked")) {
         ismilky = "1";
       } else { ismilky = "0"; }
       $.ajax({
          url: '/api/map/'+zoom+'/'+maglimit+'/'+ra+'/'+dec+'/'+mapwidth+'/'+mapheight+'/'+isgrid+'/'+isclines+'/'+isboundry+'/'+ismilky,
          beforeSend:function() {
            $('#loading').show(); 
            $('#progresstext').html("<b>Generating Map...3, 2, 1 ");
          },
          success:function(data){
            $('#progresstext').html("<b>Downloading Map...Hang Tight");
            console.log("Opening " +  'http://fuzzy-lana.s3.amazonaws.com/'+data.map+'.png');
            $("#map").attr("src", 'http://fuzzy-lana.s3.amazonaws.com/'+data.map+'.png');
            $('#loading').hide();
          }
        });
 }

window.onload=function(){
  $('#racontrol').hide();
  $('#deccontrol').hide();
  $('#loading').hide();
  
  $('#magslider').noUiSlider({
      start: [5.0],
      range: {
          'min': 1,
          'max': 8 
      }
  });  

$('#zoomslider').noUiSlider({
      start: [12.05],
      range: {
          'min': 5,
          'max': 16 
      }
  });

  $('#generate').on('click', function () {
      draw_map();
  });

  $('#popular1').on('click', function () {
      $("#ra").val("0");
      $("#dec").val("90");
      $("#zoomslider").val("14.00");
      $("#showgrid").prop('checked', true);
      draw_map(); 
  });

  $('#popular2').on('click', function () {
      $("#ra").val("6");
      $("#dec").val("0");
      $("#zoomslider").val("10.00");
      draw_map();
  });

  $('#popular3').on('click', function () {
      $("#ra").val("18");
      $("#dec").val("0");
      $("#zoomslider").val("12.00");
      draw_map();
  });

  $('#popular4').on('click', function () {
      $("#ra").val("5.5");
      $("#dec").val("0");
      $("#zoomslider").val("5.00");
      $("#showgrid").prop('checked', true);
      draw_map();
  });

  $('#popular5').on('click', function () {
      $("#ra").val("0");
      $("#dec").val("-90");
      $("#zoomslider").val("14.00");
      $("#showgrid").prop('checked', true);
      draw_map();
  });

};
