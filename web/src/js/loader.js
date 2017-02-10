exports.start = function() {
  $("input").prop("disabled", true);
  $(".loader2").addClass("visible")
  $(".loader2").removeClass("hidden")
}

exports.end = function() {
  $(".loader2").addClass("hidden")
  $(".loader2").removeClass("visible")
  $("input").prop("disabled", false);
}
