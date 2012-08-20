Given /^a player "([^"]*)" who plays like this:$/ do |player_name, content|
  create_player player_name, content
end

Given /^the correct answer to every question is '(\d+)'$/ do |answer|
  stub_correct_answer_to_be answer
end

Given /^the correct answer to every question is '(\d+)' worth (\d+) points$/ do |answer, points|
  stub_correct_answer_to_be answer, points.to_i
end

When /^the (?:player is|players are) entered$/ do
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

Then /^the log for (.+) should show:$/ do |player_name, table|
  player = players.find{ |p| p.name == player_name }
  visit player.personal_page
  actual = page.all('li').map do |li|
    li.all('div').map do |div|
      div.text
    end
  end
end
