Feature: Warm up

  Background:
    Given the server is running in warm-up mode

  Scenario:
     Given a player "bob" who plays like this:
       """
       get '/' do
         'bob'
       end
       """
     When the player is entered
     And the game is played for 1 second
     Then the scores should be:
       | player   | score |
       | bob      | 10    |
