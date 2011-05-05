Feature: Scoring

  Scenario: Player passes
    Given a player "alice" who plays like this:
      """
      get '/' do
        'PASS'
      end
      """
    And the correct answer to every question is '4'
    When the player is entered
    And the game is played for 1 second
    Then the scores should be:
      | player   | score |
      | alice    | 0     |
