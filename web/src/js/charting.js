var d3 = require('d3-time')
window.d3 = d3


var Chart = require("chart.js");
var loader = require("./loader.js");

exports.chartFunnel = function(funnel, date_range, days_to_complete) {
  var options = { title: { display: false }, legend: { display: false } };
  loader.start();
  if (funnel != 'fake' ){
    fetch(
      `/funnel/${funnel}/data?days_to_complete=${days_to_complete}&date_range=${date_range}`
    )
      .then(r => r.json())
      .then(data => drawChart("chartCanvas", "canvasContainer", "bar", data, options))
      .then(() => loader.end());
    } else {
      var data = {
          labels: ["followed_artist", "created_account"],
          datasets: [{
              label: 'count',
              data: [35394, 1542],
              backgroundColor: [
                  'rgba(255, 99, 132, 0.2)',
                  'rgba(54, 162, 235, 0.2)'
              ],
              borderColor: [
                  'rgba(255,99,132,1)',
                  'rgba(54, 162, 235, 1)'
              ],
              borderWidth: 1
          }]
      }
      drawChart("chartCanvas", "canvasContainer", "bar", data, options )
      loader.end()
    }

};

function drawChart(ctxId, containerId, type, data, options) {
	$(`#${ctxId}`).remove()
  var container = $(`#${containerId}`);
  container.append(`<canvas id="${ctxId}"></canvas>`);
  var ctx = $(`#${ctxId}`);
  new Chart(ctx, { type: type, data: data, options: options });
}

function drawLineChart(ctxId, containerId, data, options) {
    $(`#${ctxId}`).remove()
    var container = $(`#${containerId}`);
    container.append(`<canvas id="${ctxId}"></canvas>`);
    var ctx = $(`#${ctxId}`);
    new Chart(ctx, { type: type, data: data, options: options });   
}

