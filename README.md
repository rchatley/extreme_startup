Welcome
=======
This is Extreme Startup. This software supports a workshop where teams can compete to build a software product that satisfies market demand.

NB don't show the players the code for this project until after the workshop as otherwise they can cheat.

Getting started
---------------
* Install Ruby 1.9.2 and rubygems
* (For Windows)
  * Install [Ruby DevKit](http://rubyinstaller.org/downloads/)
  * Extract to (e.g.) c:\devkit
  * cd c:\devkit
  * ruby dk.rb init
  * Edit the file config.yml (Add the locations where ruby is installed e.g. c:\Ruby192)
  * ruby dk.rb install
* cd ../<exstreme startup dir>
* gem install bundler
* bundle install
* ruby web_server.rb

Notes for facilitators
----------------------

* Run the server on your machine. It's a Sinatra app that by default runs on port 3000.
* Everyone needs a computer connected to the same network, so that they can communicate. Check that everyone can see the leaderboard page served by the webapp running on your machine. Depending on the situation, we have used a local/ad-hoc network and that is ok for the game.
* We have had trouble with things like firewalls, especially on some Windows laptops, so if there are problems, make sure you can ping clients from the server and vice versa.

* Warmup round: use the WarmupQuizmaster - configure this by changing the code in lib/extreme_startup/web_server.rb around line 20(ish).
set :quizmaster_type, WarmupQuizMaster

* In the warmup round, just make sure that everyone has something technologically working, you just get the same request repeatedly.

* Real game: revert to using the full QuizMaster, and restart the server. This will clear any registered players, but that's ok.
* As the game progresses, you can introduce new question types by moving to the next round (hit the /advance_round url). Do this when you feel like some of the teams are making good progress in the current round. Typically we've found this to be about every 10 mins. But you can go faster/slower as you like. There are 6 rounds available.

* Set a time limit so you know when to stop the game, declare the winner, and retrospect.

* If you run this workshop, please let us know how it goes.

-- Robert Chatley and Matt Wynne 2011.

  