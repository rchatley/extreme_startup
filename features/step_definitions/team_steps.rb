Given /^I want to play the game$/ do
  visit '/players'
end

When /^I submit my team name and the url of my computer$/ do
  fill_in "name", :with => "Jedi masters"
  fill_in "url", :with => "http://deathstar.local"
  click_on "Submit"
end

Then /^I should see my team on the leaderboard$/ do
  visit '/'
  page.should have_content("Jedi masters")
end

Then /^I should see that my team was added$/ do
  page.should have_content("Player added - Thanks")
end

Given /^I submitted my team info$/ do
  steps %Q{
    Given I want to play the game
    When I submit my team name and the url of my computer
  }
end

Then /^I should receive a link to my market requests log$/ do
  page.should have_selector("a")
  page.first("a").click
  page.should have_content("Hello, Jedi masters")
end

Given /^I am playing$/ do
  steps %Q{
    Given I submitted my team info
  }
end

Then /^the game master should start sending me question$/ do
  player_uuid = app.players.keys.first
  app.players_threads[player_uuid].should be_alive
end

When /^I withdraw$/ do
  player_uuid = app.players.keys.first
  visit "/players/#{player_uuid}"
  click_link 'Withdraw'
end

Then /^my name should not be on the leaderboard anymore$/ do
  page.should_not have_content "Jedi masters"
end

Then /^the game master should not send me anymore questions$/ do
  app.players_threads.should be_empty
end

Then /^my player page should give a nice error$/ do
    visit '/players/no-longer-exists'
    page.should have_content("No player is registered with that id")
end