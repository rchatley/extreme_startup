require_relative 'question'

module ExtremeStartup
  class QuestionFactory
    def next_question
      return Question.new(rand(5), rand(5))
    end
  end
end