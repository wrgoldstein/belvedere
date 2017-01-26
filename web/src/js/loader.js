exports.start = function() {
  $("input").prop("disabled", true);
  $("body").append('<div class="loader"></div>');
}

exports.end = function() {
  $("input").prop("disabled", false);
  $(".loader").remove();
}
