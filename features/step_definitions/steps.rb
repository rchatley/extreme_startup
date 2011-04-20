Given /^a player "([^"]*)" who plays like this:$/ do |player_name, content|
  create_player player_name, content
end

Given /^the correct answer to every question is '(\d+)'$/ do |answer|
  stub_correct_answer_to_be answer
end

When /^the two players are entered$/ do
  players.each do |player|
    player.start
    enter_player player
  end
end

When /^the game is played for (\d+) second$/ do |num_seconds|
  sleep num_seconds.to_i
end

Then /^the scores should be:$/ do |table|
  table.hashes.each do |row|
    score_for(row['player']).should == row['score'].to_i
  end
end
