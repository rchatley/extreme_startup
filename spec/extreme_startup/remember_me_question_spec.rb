module ExtremeStartup
  describe RememberMeQuestion do
    let(:player)   { Player.new("player one") }
    let(:question) { RememberMeQuestion.new(player, 0) }
      
    context "first time a client talks to a player" do
      it "tells its name" do
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
    end
    
    context "player gave the wrong answer the first time" do
      let(:first_session_name) {
        question.as_text =~ /my name is (.*)\./
        $1        
      }
      let(:second_question) { 
        question.answer = "the wrong name"
        RememberMeQuestion.new(player,0)
      }
      
      it "gives new session" do
        second_question.as_text =~ /my name is (.*)\./
        second_name = $1
        second_name == first_session_name
      end
    end
    
    context "player gave the right answer the first time" do
      let(:first_session_name) {
        question.as_text =~ /my name is (.*)\./
        $1        
      }
      let(:second_question) { 
        question.answer = first_session_name
        RememberMeQuestion.new(player,0)
      }
      
      it "doesn't tell its name again" do
        second_question.as_text.should_not =~ /my name is/
      end
      
      it "is correct when its name is given" do
        question.answer = first_session_name
        question.score.should > 0        
      end
      
      it "is wrong when another name is given" do
        question.answer= "the wrong name"
        question.score.should < 0
      end
      
    end
  end
end
