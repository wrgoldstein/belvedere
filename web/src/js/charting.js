var d3 = require('d3-time-format')
window.d3 = d3


var Chart = require("chart.js");
var loader = require("./loader.js");

var BG_COLORS = [
  'rgba(255, 99, 132, 0.2)',
  'rgba(54, 162, 235, 0.2)',
  'rgba(255, 206, 86, 0.2)',
  'rgba(75, 192, 192, 0.2)',
  'rgba(153, 102, 255, 0.2)',
  'rgba(255, 159, 64, 0.2)'
]


var BORDER_COLORS = [
  'rgba(255,99,132,1)',
  'rgba(54, 162, 235, 1)',
  'rgba(255, 206, 86, 1)',
  'rgba(75, 192, 192, 1)',
  'rgba(153, 102, 255, 1)',
  'rgba(255, 159, 64, 1)'
]


var OPTIONS = {
    title: { display: false },
    scales: {
        yAxes: [{
            ticks: {
                beginAtZero: true
            }
        }]
    }
  };

exports.chartFunnel = function(funnel, date_range, days_to_complete) {
  var additional_options = { legend: { display: false } }
  loader.start();
  var url = `/funnel/${funnel}/data?days_to_complete=${days_to_complete}&date_range=${date_range}`
  fetch( url, { credentials: 'same-origin' })
    .then(r => r.json())
    .then(data => prepareFunnelData(data))
    .then(data => drawChart("chartCanvas", "canvasContainer", "bar", data, _.merge(OPTIONS, additional_options)))
    .then(() => loader.end())
    .catch(function(error) {
        console.log('There has been a problem with your fetch operation: ' + error.message)
        loader.end()
    });
};

exports.chartSegment = function(project, events, date_range){
  loader.start();
  var url = `/segment/data?project=${project}&events=${events}&date_range=${date_range}`
  fetch(url, { credentials: 'same-origin' })
    .then(r => r.json())
    .then(data => prepareSegmentData(data))
    .then(data => drawChart("chartCanvas", "canvasContainer", "line", data, OPTIONS))
    .then(() => loader.end())
    .catch(function(error) {
        console.log('There has been a problem with your fetch operation: ' + error.message)
        loader.end()
    });
}

function drawChart(ctxId, containerId, type, data, options) {
  if (data == null) {
    console.log("No data for selection")
    return
  }
	$(`#${ctxId}`).remove()
  var container = $(`#${containerId}`);
  container.append(`<canvas id="${ctxId}"></canvas>`);
  var ctx = $(`#${ctxId}`);
  new Chart(ctx, { type: type, data: data, options: options });
}

function prepareFunnelData(data){
  data = _.sortBy(data, (e) => -e.count)
  labels = _.map(data, (e) => e.event)
  values = _.map(data, (e) => e.count)
  return {
    labels: labels,
    datasets: [{
      label: 'count',
      data: values,
      backgroundColor: BG_COLORS.slice(0, labels.length - 1),
      borderColor: BORDER_COLORS.slice(0, labels.length - 1),
      borderWidth: 1
      }]
  }
}

function prepareSegmentData(data){
  window.rawData = data
  if (data.length == 0) return
  data = _.sortBy(data, (d) => d.date)
  var dates = _.uniq(_.map(data, (d) => d.date ))
  var events = _.uniq(_.map(data, (d) => d.event ))
  var datasets = events.map( (event, i) => {
    var series = _.filter(data, (d) => d.event == event)
    return {
      label: event,
      fill: false,
      lineTension: 0.1,
      backgroundColor: BG_COLORS[i],
      borderColor: BORDER_COLORS[i],
      borderCapStyle: 'butt',
      borderDash: [],
      borderDashOffset: 0.0,
      borderJoinStyle: 'miter',
      pointBorderColor: BORDER_COLORS[i],
      pointBackgroundColor: "#fff",
      pointBorderWidth: 1,
      pointHoverRadius: 5,
      pointHoverBackgroundColor: BG_COLORS[i],
      pointHoverBorderColor: BORDER_COLORS[i],
      pointHoverBorderWidth: 2,
      pointRadius: 1,
      pointHitRadius: 10,
      data: _.map(series, (d) => d.count),
      spanGaps: false,
    }
  })
  return {
    labels: dates,
    datasets: datasets
  }
}
