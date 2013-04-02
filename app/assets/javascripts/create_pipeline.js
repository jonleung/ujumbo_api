$(document).ready(function() {
  
  $(function () {
    $('a[data-toggle="tab"]').on('shown', function (e) {
      console.log("activated")
      console.log(e.target)
      console.log("previous")
      console.log(e.relatedTarget)
    })
  })


  var create_template_pipe = function() {
    template_pipe = $("#pipes").append($("#template_pipe_template").html())
    $(template_pipe).find("#type_text").keyup(function() {
        var str = $(this).val();
        if(str.charAt( str.length-1 ) == ":" && str.match(/:::(.*?):::/)) {
              var temp = str.match(/:::(.*?):::/)[1];
              var field = temp.charAt(0).toUpperCase() + temp.slice(1);
              $("#template").append('<div><p id="submit_field">' + field + ': </p>' + '<input id="submit_text" type="text"></input></div>');    
            }
        $("#submit_field").hide();
        $("#submit_text").hide();
  })

  }

  $("#create_new").change(function(e){
    var type = $("#create_new option:selected").attr("value")
    if (type == "sms")
      create_sms_pipe(1)
    if (type == "email")
      create_email_pipe(1)
    if (type == "google_doc")
      create_google_doc_pipe(1)
    if (type == "template")
      create_template_pipe()
  })

  // create_tempalte_pipe()



});

