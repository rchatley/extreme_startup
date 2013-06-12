$(document).ready(function () {
        var MAX_LENGTH = 100;
        var colourTable = {}

        var Graph = function () {
            var timeSeries = {};
            var randomRgbValue = function () {
                return Math.floor(Math.random() * 156 + 99);
            }
            var randomColour = function () {
                return 'rgb(' + [randomRgbValue(), randomRgbValue(), randomRgbValue()].join(',') + ')';
            }
            var getSeries = function (pid) {
                return timeSeries[pid];
            }
            this.updateWith = function (leaderboard) {
                for (var i = 0; i < leaderboard.length; i += 1) {
                    var entry = leaderboard[i];
                    var series = timeSeries[entry.playerid];
                    if (!series) {
                        colourTable[entry.playerid] = randomColour();
                        series = timeSeries[entry.playerid] = {
                            label: entry.playername,
                            data: [],
                            lines: { lineWidth: 0.8},
                            color: colourTable[entry.playerid]};
                    }
                    if(series.data.length > MAX_LENGTH) {
                        series.data.shift();
                    }
                    series.data.push([new Date().getTime(), entry.score]);
                }
                var elems = [];
                for (var p in timeSeries) {
                    if (timeSeries.hasOwnProperty) {
                        elems.push(timeSeries[p]);
                    }
                }
                $.plot($('#mycanvas'), elems,
                    {xaxis: {mode: "time"},
                    legend: {show: false}});
            };
        };

        var ScoreBoard = function (div) {
            this.updateWith = function (leaderboard) {
                var list = $('<ul id="scoreboard"></ul>');
                for (var i = 0; i < leaderboard.length; i += 1) {
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

        var graph = new Graph();  // get DOM object from jQuery object
        var scoreboard = new ScoreBoard($('#scoreboard'));

        setInterval(function () {
            $.ajax({
                url: '/scores',
                success: function (data) {
                    var leaderboard = JSON.parse(data);
                    if (leaderboard.inplay) {
                        graph.updateWith(leaderboard.entries);
                        scoreboard.updateWith(leaderboard.entries);
                    }
                }
            });
        }, 10000);
    }
);