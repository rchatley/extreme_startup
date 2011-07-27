Feature: A team can register to the game
  In order to show everyone that we are the best
  As a team
  I want to be able to register my team
  
  Scenario: Add team
    Given I want to play the game
    When I submit my team name and the url of my computer
    Then I should see that my team was added
    And I should see my team on the leaderboard
  
  Scenario: When added team receives a link to its log
    Given I submitted my team info
    Then I should receive a link to my market requests log
  
  Scenario: Start receiving questions
    Given I am playing
    Then the game master should start sending me question