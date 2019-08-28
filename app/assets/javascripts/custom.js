function initChart1() {
  // chart 1 dashboard page
  var chart1 = document.getElementById('chartjs-barchart');
  var jobRequestsMax = Math.max.apply(null, $(chart1).data("job-requests"));
  var jobsMax = Math.max.apply(null, $(chart1).data("jobs"));
  var barctx = chart1.getContext('2d');

  var barData = {
    labels: ['January', 'February', 'March', 'April', 'May', 'June', 'July', "August", "September", "October", "November", "December"],
    datasets: [{
      label: "Job",
      backgroundColor: '#23b7e5',
      borderColor: '#23b7e5',
      data: $(chart1).data("jobs")
    }, {
      label: "Job Request",
      backgroundColor: '#5d9cec',
      borderColor: '#5d9cec',
      data: $(chart1).data("job-requests")
    }]
  };

  var barOptions = {
    legend: {
      display: true
    },
    scales: {
        yAxes: [{
            ticks: {
                min: 0,
                stepSize: setStepSize([jobsMax, jobRequestsMax])
            }
        }]
    }
  };

  var barChart = new Chart(barctx, {
    data: barData,
    type: 'bar',
    options: barOptions
  });
}

function initChart2() {
  // chart 2 dashboard page
  var chart2 = $('#chart-splinev2');
  var jobRequestsMax = Math.max.apply(null, $(chart2).data("job-requests"));
  var jobsMax = Math.max.apply(null, $(chart2).data("jobs"));
  var usersMax = Math.max.apply(null, $(chart2).data("users"));
  var datav2 = [
    {
      "label": "Users",
      "color": "#0abe51",
      "data": chart2.data("users")
    },
    {
      "label": "Jobs",
      "color": "#23b7e5",
      "data": chart2.data("jobs")
    },
    {
      "label": "Job Requests",
      "color": "#7266ba",
      "data": chart2.data("job_requests")
    }];

  var chart2Options = {
    series: {
      lines: {
        show: false
      },
      points: {
        show: true,
        radius: 4
      },
      splines: {
        show: true,
        tension: 0.4,
        lineWidth: 1,
        fill: 0.5
      }
    },
    grid: {
      borderColor: '#eee',
      borderWidth: 1,
      hoverable: true,
      backgroundColor: '#fcfcfc'
    },
    tooltip: true,
    tooltipOpts: {
      content: function(label, x, y) { return label + ' : ' + y; }
    },
    xaxis: {
      tickColor: '#fcfcfc',
      mode: 'categories'
    },
    yaxis: {
      // min: 0,
      // max: 100, // optional: use it for a clear represetation
      tickColor: '#eee',
      //position: 'right' or 'left',
      tickSize: setStepSize([jobsMax, jobRequestsMax, usersMax]),
      tickFormatter: function(v) {
        return v /* + ' visitors'*/ ;
      }
    },
    shadowSize: 0
  };

  $.plot($('#chart-splinev2'), datav2, chart2Options);
}

function setStepSize(array) {
  var stepSizeValue;
  if (Math.max.apply(null, array) < 10) {
    stepSizeValue = 1
  } else if (Math.max.apply(null, array) < 50) {
    stepSizeValue = 5
  } else if (Math.max.apply(null, array) < 100) {
    stepSizeValue = 10
  } else if (Math.max.apply(null, array) < 500) {
    stepSizeValue = 50
  } else {
    stepSizeValue = 100
  };
}