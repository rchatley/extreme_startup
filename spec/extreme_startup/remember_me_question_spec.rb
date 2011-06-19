module ExtremeStartup
  describe RememberMeQuestion do
    let(:player)   { Player.new("player one") }
    let(:question) { RememberMeQuestion.new(player, 0) }

    it "tells its name the first time" do
      question.as_text.should =~ /my name is/
    end
    
    it "is correct when the name is echoed" do
      question.as_text =~ /my name is (.*)\./
      question.answer = $1
      question.score.should > 0
    end
    
    it "is wrong when another name is echoed" do
      question.answer = "the wrong name"
      question.score.should < 0
    end
    
    it "gives new session when answered wrong" do
      question.as_text =~ /my name is (.*)\./
      first_name = $1
      question.answer = "the wrong name"
      question = RememberMeQuestion.new(player,0)
      question.as_text =~ /my name is (.*)\./
      second_name = $1
      first_name.should_not == second_name
    end
    
    it "doesn't tell it's name twice" do
      question.as_text =~ /my name is (.*)\./
      question.answer = $1
      question = RememberMeQuestion.new(player,0)
      question.as_text.should_not =~ /my name is/
    end
    
    it "expects the same name twice" do
      question.as_text =~ /my name is (.*)\./
      question.answer = $1
      question = RememberMeQuestion.new(player,0)
      question.as_text.should_not =~ /my name is/
      question.answer = $1
      question.score.should > 0
    end

    it "does not accept another name the second round" do
      question.as_text =~ /my name is (.*)/
      name = $1
      question.answer = name
      question = RememberMeQuestion.new(player,0)
      question.answer= "the wrong name"
      question.score.should < 0
    end    
  end
end
