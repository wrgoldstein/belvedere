var $ = require("jquery");
var _ = require("lodash");
window.$ = $;
window._ = _;
window.sd = {};
window.sd.templates = require("./templates")

var chart = require("./charting");

sd.chartFunnel = chart.chartFunnel;
sd.chartSegment = chart.chartSegment;

var Autosuggest = require("./autosuggest")

window.sd.Autosuggest = Autosuggest;


//chart();

// function setCanvasSize(){
//   var margin = .2
//   var window_width = $(window).width()
//   var window_height = $(window).height()


//   $('#chartCanvas').width()
// }