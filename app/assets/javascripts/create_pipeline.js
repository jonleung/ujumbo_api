$(document).ready(function() {
  
  $(function () {
    $('a[data-toggle="tab"]').on('shown', function (e) {
      console.log("activated")
      console.log(e.target)
      console.log("previous")
      console.log(e.relatedTarget)
    })
  })

});

