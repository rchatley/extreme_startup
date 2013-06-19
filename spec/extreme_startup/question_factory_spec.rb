require 'spec_helper'
require 'extreme_startup/question_factory'
require 'extreme_startup/player'

class File
  def File.remove (filename)
    File.delete(filename) if File.exist?(filename)    
  end
end

module ExtremeStartup
  describe QuestionFactory do
    let(:player)  { Player.new("player one") }
    let(:factory) { QuestionFactory.new }

    context 'when created' do
      
      after(:each) do
        File.remove('question_factory.yaml')
        File.remove('question_factory_test.yaml')
      end
      
      it 'can send yaml profile listing question classes to stream' do
        io = StringIO.new
        factory.save_profile(io)

        io.string.should match '.*class.*ExtremeStartup::AdditionQuestion.*'
      end

      it "default streaming profile to 'question_factory.yaml' file" do
        factory.save_profile()

        File.file?('question_factory.yaml').should be_true
      end

      it 'loads questions list from given file if it exists' do

        File.open('question_factory_test.yaml','w') do |file|
          file.puts '---'
          file.puts "- !ruby/class 'ExtremeStartup::AdditionQuestion'"
        end

        factory = QuestionFactory.new('question_factory_test.yaml')
        questions = 20.times.map { factory.next_question(player) }
        questions.all? { |q| q.class == AdditionQuestion }
      end

      it 'loads questions list from default file "question_factory.yaml" if it exists' do

        File.open('question_factory.yaml','w') do |file|
          file.puts '---'
          file.puts "- !ruby/class 'ExtremeStartup::MultiplicationQuestion'"
        end

        factory = QuestionFactory.new
        questions = 20.times.map { factory.next_question(player) }
        questions.all? { |q| q.class == MultiplicationQuestion }
      end

    end

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
    
    context "in the third round" do
      before(:each) do
        factory.advance_round
        factory.advance_round
      end
      
       it "moves a sliding window forward, keeping 5 question types, so AdditionQuestions no longer appear" do
          questions = 30.times.map { factory.next_question(player) }
          questions.any? { |q| q.is_a?(AdditionQuestion) }.should be_false
          questions.any? { |q| q.is_a?(MaximumQuestion) }.should be_true
          questions.any? { |q| q.is_a?(MultiplicationQuestion) }.should be_true
          questions.any? { |q| q.is_a?(SquareCubeQuestion) }.should be_true
          questions.any? { |q| q.is_a?(MultiplicationQuestion) }.should be_true
          questions.any? { |q| q.is_a?(SquareCubeQuestion) }.should be_true
          questions.all? { |q| [MaximumQuestion, MultiplicationQuestion, SquareCubeQuestion, GeneralKnowledgeQuestion, PrimesQuestion].include? q.class }
        end
     
    end
         
  end
end
