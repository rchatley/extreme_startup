Feature: Compete

  Scenario: One player plays another
    Given a player "dumbo" who plays like this:
      """
      get '/' do
        'PASS'
      end
      """
    And a player "always-4" who plays like this:
      """
      get '/' do
        '4'
      end
      """
    And the correct answer to every question is '4' worth 10 points
    When the two players are entered
    And the game is played for 1 second
    Then the scores should be:
      | player   | score |
      | always-4 | 10    |
      | dumbo    | -1    |
      
