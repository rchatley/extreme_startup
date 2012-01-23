Feature: A team can withdraw from the game
  In order to be considered as big loosers
  As a team
  I want to be able to withdraw from the game
  
  Scenario: Withdraw
    Given I am playing
    When I withdraw
    Then my name should not be on the leaderboard anymore
    And my player page should give a nice error
    And the game master should not send me anymore questions