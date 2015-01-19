function draw_map(){
       var spots ;
       var zoom = $("#slider").val() /100;
       var width = $("#mapdiv").width();
       // Set map height based on the width
       $("#mapdiv").height(width-200);
       var height = $("#mapdiv").height();
       // Override width and height with static values
       width = 1000 
       height = 1200
       var mapwidth = parseFloat(width);
       var mapheight = parseFloat(height);
       var ra = $("#ra").val();
       var dec = $("#dec").val();
       var isgrid = 1;
       var isclines = 0;
       var maglimit = $('#magslider').val();
       var ngcmaglimit = $('#ngcmagslider').val();
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
          url: '/api/map/'+zoom+'/'+maglimit+'/'+ra+'/'+dec+'/'+mapwidth+'/'+mapheight+'/'+isgrid+'/'+isclines+'/'+isboundry+'/'+ismilky+'/'+ngcmaglimit,
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
  //$('#racontrol').hide();
  //$('#deccontrol').hide();
  $('#loading').hide();
  $('#showmw').hide();
  
  $("#ra").val("0.0");
  $("#dec").val("37.0");  
  $( "#cselect" )
    .change(function () {
      var str = ""
      $( "select option:selected" ).each(function() {
        str += $( this ).val() + " ";
      });
      $("#ra").val(str.split("z")[0]);
      $("#dec").val(str.split("z")[1]);
      console.log(str);
  }); 


  $('#magslider').noUiSlider({
      start: [5.0],
      range: {
          'min': 1,
          'max': 8 
      }
  });  

  $('#ngcmagslider').noUiSlider({
      start: [8.0],
      range: {
          'min': 1,
          'max': 12 
      }
  });

$('#zoomslider').noUiSlider({
      start: [8.00],
      step: 1,
      range: {
          'min': 3, 
          'max': 10 
      }
  });

  $('#generate').on('click', function () {
      draw_map();
  });

};
