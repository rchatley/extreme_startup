Feature: Penalty Rules

  Penalty for failure depends on your league position.
  
  If you get a question wrong, your score is reduced by X, where X is the potential value of the question, divided by your current leaderboard position. So, the higher you are on the leaderboard, the more penalty you suffer for getting the same question wrong.
  
  i.e.
  
  X = Value / Position
  
  When the game starts, initial leaderboard position is determined by the order in which you entered.

  Scenario: One player plays another
  
    Given a player "always-right" who plays like this:
      """
      get('/') { '0' }
      """
    Given a player "always-wrong" who plays like this:
      """
      get('/') { 'PASS' }
      """
    And the correct answer to every question is '0' worth 10 points
    When the players are entered
    And the game is played for 1 second
    Then the scores should be:
      | player         | score |
      | always-right   | 10    |
      | always-wrong   | -5    |