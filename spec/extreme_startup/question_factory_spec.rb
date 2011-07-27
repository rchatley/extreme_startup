require 'spec_helper'
require 'extreme_startup/question_factory'
require 'extreme_startup/player'

module ExtremeStartup
  describe QuestionFactory do
    let(:player)  { Player.new("player one") }
    let(:factory) { QuestionFactory.new }
    
    context "in the first round" do
       it "creates both AdditionQuestions and SquareCubeQuestion" do
          questions = 10.times.map { factory.next_question(player) }
          questions.any? { |q| q.is_a?(AdditionQuestion) }.should be_true
          questions.any? { |q| q.is_a?(MaximumQuestion) }.should be_true
          questions.all? { |q| [AdditionQuestion, MaximumQuestion].include? q.class }
        end
    end
    
    context "in the second round" do
      before(:each) do
        factory.advance_round
      end
      
       it "creates four different types of question" do
          questions = 20.times.map { factory.next_question(player) }
          questions.any? { |q| q.is_a?(AdditionQuestion) }.should be_true
          questions.any? { |q| q.is_a?(MaximumQuestion) }.should be_true
          questions.any? { |q| q.is_a?(MultiplicationQuestion) }.should be_true
          questions.any? { |q| q.is_a?(SquareCubeQuestion) }.should be_true
          questions.all? { |q| [AdditionQuestion, MaximumQuestion, MultiplicationQuestion, SquareCubeQuestion, ].include? q.class }
        end
     
    end
         
  end
end
