require 'spec_helper'
require 'extreme_startup/question_factory'

module ExtremeStartup
  describe QuestionFactory do
    let(:factory) { QuestionFactory.new }
    
    context "in the first round" do
      it "tends to only create AdditionQuestions" do
        10.times do
          factory.next_question.should be_instance_of AdditionQuestion
        end
      end
    end
    
    context "in the second round" do
      before(:each) do
        factory.advance_round
      end
      
      it "creates both AdditionQuestions and MultiplicationQuestions" do
        questions = 10.times.map { factory.next_question }
        questions.any? { |q| q.is_a?(AdditionQuestion) }.should be_true
        questions.any? { |q| q.is_a?(MultiplicationQuestion) }.should be_true
        questions.all? { |q| [AdditionQuestion, MultiplicationQuestion].include? q.class }
      end
    end
         
  end
end
