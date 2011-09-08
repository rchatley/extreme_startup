Feature: Penalty Rules

  Penalty for failure depends on your league position.
  
  If you get a question wrong, your score is reduced by X, where X is the potential value of the question, divided by your current leaderboard position. So, the higher you are on the leaderboard, the more penalty you suffer for getting the same question wrong.
  
  i.e.
  
  X = Value / Position
  
  When the game starts, initial leaderboard position is determined by the order in which you entered.

  Scenario: One player plays another
    Given a player "keen-but-wrong" who plays like this:
      """
      get('/') { 'PASS' }
      """
    Given a player "also-wrong" who plays like this:
      """
      get('/') { 'PASS' }
      """
    And a player "always-4" who plays like this:
      """
      get('/') { '4' }
      """
    And the correct answer to every question is '4' worth 10 points
    When the players are entered
    And the game is played for 1 second
    Then the scores should be:
      | player         | score |
      | always-4       | 10    |
      | also-wrong     | -5    |
      | keen-but-wrong | -10   |
      
