$(document).ready(function() {
	var colourTable = {}

	var Graph = function(canvas) {
		var timeSeries = {};
		var smoothie = new SmoothieChart({millisPerPixel: 500});
		smoothie.streamTo(canvas, 1000); 
		var randomRgbValue = function () {
			return Math.floor(Math.random() * 156 + 99);
		}
		var randomColour = function () {
			return 'rgb(' + [randomRgbValue(), randomRgbValue(), randomRgbValue()].join(',') + ')';
		}
		this.updateWith = function (leaderboard) {
			for (var i=0; i < leaderboard.length; i += 1) {
				var entry = leaderboard[i];
				var series = timeSeries[entry.playerid];
				if (!series) {
					series = timeSeries[entry.playerid] = new TimeSeries();
					colourTable[entry.playerid] = randomColour();
					smoothie.addTimeSeries(series, { strokeStyle:colourTable[entry.playerid], lineWidth:3 });
				}
				series.append(new Date().getTime(), entry.score);
				smoothie.start();
			}
		};
		this.pause = function() {
			smoothie.stop();
		}
	};  

	var ScoreBoard = function(div) {
		this.updateWith = function (leaderboard) {
			var list = $('<ul id="scoreboard"></ul>');            
			for (var i=0; i < leaderboard.length; i += 1) {
				var entry = leaderboard[i];
				list.append(
					$('<div/>').append(
						$('<li/>', {class: "player"})
						.append($('<div>' + entry.playername + '</div>').addClass("ranking name").css("background-color", colourTable[entry.playerid]))
						.append($('<div>' + entry.score + '</div>').addClass("ranking points").css("background-color", colourTable[entry.playerid]))
						.append($('<a>Withdraw</a>').attr("href", "/withdraw/" + entry.playerid))));
				}
				$("#scoreboard").replaceWith(list); 
			}
		};

		var graph = new Graph($('#mycanvas')[0]);  // get DOM object from jQuery object
		var scoreboard = new ScoreBoard($('#scoreboard'));

		setInterval(function() {
			$.ajax({
				url: '/scores',
				success: function( data ) {
					var leaderboard = JSON.parse(data);
					if (leaderboard.inplay) {
						graph.updateWith(leaderboard.entries);
						scoreboard.updateWith(leaderboard.entries);
					} else {
						graph.pause();
					}
				}
			});
		}, 1000);
	}
);