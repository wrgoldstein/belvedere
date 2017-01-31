exports.start = function() {
  $("input").prop("disabled", true);
  $(".loader").addClass("visible")
  $(".loader").removeClass("hidden")
}

exports.end = function() {
  $(".loader").addClass("hidden")
  $(".loader").removeClass("visible")
  $("input").prop("disabled", false);
}
