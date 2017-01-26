var Chart = require('chart.js')
var loader = require('./loader.js')

exports.chartFunnel = function(funnel) {
	$('#chartCanvas').remove()
	$('.canvasContainer').append(`<canvas id="chartCanvas"></canvas>`)
	var ctx = $("#chartCanvas");
	loader.start()
	fetch(`/funnel/${funnel}/data?days_to_convert=7&date_range=last30days`)
	  .then(r => r.json())
      .then(data => {
            new Chart(ctx, {
        	    type: 'bar',
        	    data: data,
        	    options: {
        	    	title: {
        	    		display: false
        	    	},
        	    	legend: {
        	    		display: false
        	    	}
        	    }
        	})
      })
      .then( () => loader.end() )
}

function generate_fake_chart() {
	var myArray = [fakeLineChart, fakeBarChart]
	var rand = myArray[Math.floor(Math.random() * myArray.length)];
	rand();
}

function fakeLineChart() {
	var data = {
	    labels: ["January", "February", "March", "April", "May", "June", "July"],
	    datasets: [
	        {
	            label: "My First dataset",
	            fill: false,
	            lineTension: 0.1,
	            backgroundColor: "rgba(75,192,192,0.4)",
	            borderColor: "rgba(75,192,192,1)",
	            borderCapStyle: 'butt',
	            borderDash: [],
	            borderDashOffset: 0.0,
	            borderJoinStyle: 'miter',
	            pointBorderColor: "rgba(75,192,192,1)",
	            pointBackgroundColor: "#fff",
	            pointBorderWidth: 1,
	            pointHoverRadius: 5,
	            pointHoverBackgroundColor: "rgba(75,192,192,1)",
	            pointHoverBorderColor: "rgba(220,220,220,1)",
	            pointHoverBorderWidth: 2,
	            pointRadius: 1,
	            pointHitRadius: 10,
	            data: [65, 59, 80, 81, 56, 55, 40],
	            spanGaps: false,
	        }
	    ]
	};

	new Chart(ctx, {
	    type: 'line',
	    data: data
	});
}

function fakeBarChart() {
	new Chart(ctx, {
	    type: 'bar',
	    data: {
	        labels: ["Red", "Blue", "Yellow", "Green", "Purple", "Orange"],
	        datasets: [{
	            label: '# of Votes',
	            data: [12, 19, 3, Math.random() * 10, 2, 3],
	            backgroundColor: [
	                'rgba(255, 99, 132, 0.2)',
	                'rgba(54, 162, 235, 0.2)',
	                'rgba(255, 206, 86, 0.2)',
	                'rgba(75, 192, 192, 0.2)',
	                'rgba(153, 102, 255, 0.2)',
	                'rgba(255, 159, 64, 0.2)'
	            ],
	            borderColor: [
	                'rgba(255,99,132,1)',
	                'rgba(54, 162, 235, 1)',
	                'rgba(255, 206, 86, 1)',
	                'rgba(75, 192, 192, 1)',
	                'rgba(153, 102, 255, 1)',
	                'rgba(255, 159, 64, 1)'
	            ],
	            borderWidth: 1
	        }]
	    },
	    options: {
	        scales: {
	            yAxes: [{
	                ticks: {
	                    beginAtZero:true
	                }
	            }]
	        }
	    }
	});
}
