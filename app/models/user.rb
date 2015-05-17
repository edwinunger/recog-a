require 'bcrypt'

class User < ActiveRecord::Base
  has_many :quizzes

  def password
    @password ||= BCrypt::Password.new(password_hash) if password_hash.present?
  end

  def password=(my_password)
    @password = BCrypt::Password.create(my_password)
    self.password_hash = @password
  end
end