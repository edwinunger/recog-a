class Question < ActiveRecord::Base
  belongs_to :quiz
  has_many :choices
  has_many :responses


  # def next
  #   index = survey.questions.find_index(self)
  #   survey.questions[index+1]
  # end



end

