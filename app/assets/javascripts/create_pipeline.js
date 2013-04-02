$(document).ready(function() {
  
  $(function () {
    $('a[data-toggle="tab"]').on('shown', function (e) {
      console.log("activated")
      console.log(e.target)
      console.log("previous")
      console.log(e.relatedTarget)
    })
  })

  $("#type_text").keyup(function () {
        var str = $(this).val();
        if(str.charAt( str.length-1 ) == ":" && str.match(/:::(.*?):::/)) {
              var temp = str.match(/:::(.*?):::/)[1];
              var field = temp.charAt(0).toUpperCase() + temp.slice(1);
              $("#template").append('<div><p id="submit_field">' + field + ': </p>' + '<input id="submit_text" type="text"></input></div>');    
            }
        $("#submit_field").hide();
        $("#submit_text").hide();
    });

});

