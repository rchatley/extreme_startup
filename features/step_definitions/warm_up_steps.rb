Given /^the server is running in warm\-up mode$/ do
  app.question_factory = ExtremeStartup::WarmupQuestionFactory.new
end
