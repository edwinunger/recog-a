require 'httparty'
require 'json'
require 'awesome_print'
require 'pry'
require 'dotenv'

get '/' do
  if logged_in?
    redirect '/my_quizzes'
  end
  erb :index
end

get '/users/new' do
  erb :new_user
end

post '/users' do
  @user = User.new(
    first_name: params[:first_name],
    last_name: params[:last_name],
    email: params[:email],
    birth_date: params[:birth_date],
    diagnosed_date: params[:diagnosed_date])
  @user.password = params[:password]

  @quizzes = Quiz.where(user_id: @user.id)

  if @user.save
    login(@user)

    client = SendGrid::Client.new(
      api_user: 'edwinunger',
      api_key: 'Ehu51783')

    mail = SendGrid::Mail.new do |m|
      m.to = @user.email
      m.from = 'noreply@recog.org'
      m.subject = 'Welcome to Recog-A!'
      m.html =
        "<html>
        <head>
          <style type='text/css'>
          </style>
        </head>
          <body>
            Dear #{@user.first_name},
            <br>
            <br>
            Thank you for creating an account with Recog-A. In order to get started, please head to <a href='http://127.0.0.1:9393/'>the login page</a>. We look forward to being here to support you through your new journey.
              <br>
              <br>
              Thank you,
              <br>
              <br>
              The Recog-A Team
            </body>
          </html>"
    end

    puts client.send(mail)

    redirect '/my_quizzes'
  else
    status 400
    "Unable to create profile. Please make sure your information is correct, and that you don't already have an account with Recog-A."
    redirect '/users/new'
  end
end

get '/login/new' do
  erb :login
end

post '/login' do
  @user = User.where(email: params[:email]).first
  if @user && @user.password == params[:password]
    login(@user)
    redirect '/my_quizzes'
  else
    status 400
    "You have either entered an incorrect password, or we don't have this email on file. Please try again."
    redirect '/login/new'
  end
end

get '/my_quizzes' do
  if logged_in?
    @user = User.find(current_user.id)
    @quizzes = Quiz.where(user_id: current_user.id)

    @scores = []
    @quizzes.each do |quiz|
      @title = quiz.title
      quiz.results.each do |result|
        @scores << result.score.to_i
      end
    end
    erb :my_page
  else
    redirect '/login/new'
  end
end

delete '/logout' do
  logout
  redirect '/'
end

get '/quiz/new' do
  erb :new_quiz
end

post '/quiz' do
  @quiz = Quiz.new(
      user_id: current_user.id,
      title: params[:title])


  if @quiz.save
    "Recog created."
    redirect '/my_quizzes'
  end
end

get '/quiz/:id' do
  @quiz = Quiz.where(id: params[:id]).first
  @user = User.find(@quiz.user_id)
  @questions = Question.where(quiz_id: @quiz.id)
  @questions.each do |question|
    @choices = Choice.where(question_id: question.id)
  end

  erb :quiz
end

get '/quiz/:id/take_quiz' do
  @quiz = Quiz.where(id: params[:id]).first
  @user = User.find(@quiz.user_id)
  erb :take_quiz
end

post '/question' do

  @filename = params['upload'][:filename]
  file = params['upload'][:tempfile]

  File.open("./public/#{@filename}", 'wb') do |f|
    f.write(file.read)
  end

  reply = HTTParty.post 'https://api.imgur.com/3/upload.json',
  :headers => { 'Authorization' => "Client-ID e9c2241792a58f8" },
  :body    => { 'image' => Base64.encode64(File.read("./public/#{@filename}")) }

  @image = reply['data']['link']
  ap reply
  ap @image

  @question = Question.new(
    quiz_id: params[:quiz_id],
    question: params[:question],
    image_url: @image)

  if @question.save
    @correct_choice = [
      params[:correct_choice]]

    @correct_choice.each do |choice|
      @correct = Choice.create(
        question_id: @question.id,
        choice: choice,
        correct: true)
    end

    @incorrect_choices = [
      params[:incorrect_choice_1],
      params[:incorrect_choice_2],
      params[:incorrect_choice_3]]

    @incorrect_choices.each do |choice|
      @incorrect = Choice.create(
        question_id: @question.id,
        choice: choice,
        correct: false)
    end

    redirect "/quiz/#{@question.quiz_id}"
  else
    status 400
    "Unable to create question."
  end
end


get '/question/:id' do
  @question = Question.find(params[:id])
  erb :question
end

delete '/question/:id' do
  @question = Question.where(id: params[:id]).first
  @question.destroy
end

post '/quiz/:id/responses' do
  @question = Question.find(params[:id])
  @quiz = Quiz.find(@question.quiz_id)
  @user = User.find(@quiz.user_id)
  @reply = Response.new(
    question_id: @question.id,
    response: params[:choice],
    correct: false)
  @question.responses << @reply
  @reply.save
  @choice = Choice.where(id: @reply.response).first
  @reply.update(correct: @choice.correct)
  client = SendGrid::Client.new(
      api_user: 'edwinunger',
      api_key: 'Ehu51783')

  mail = SendGrid::Mail.new do |m|
    m.to = @user.email
    m.from = 'noreply@recog.org'
    m.subject = 'Thank you for completing the Recog!'
    m.html =
      "<html>
        <head>
          <style type='text/css'>
          </style>
        </head>
        <body>
          Dear #{@user.first_name},
          <br>
          <br>
          Great job completing your Recog! You can go to <a href='http://127.0.0.1:9393/'>your profile page</a> to see your results for all Recogs.
          <br>
          <br>
          We recommend retaking the Recog at regular intervals to get more accurate and immediate results regarding any changes in your short and long-term memory.
          <br>
          <br>
          Thank you,
          <br>
          <br>
          The Recog-A Team
        </body>
      </html>"
  end

  puts client.send(mail)
  @reply.to_json
end

get '/quiz/:id/results' do
  @quiz = Quiz.find(params[:id])
  @right = 0
  @wrong = []
  @last_quiz = Response.last(@quiz.questions.length)
  @last_quiz.each do |response|
    if response.correct == true
      @right += 1
    elsif response.correct == false
      @wrong << Question.find(response.question_id)
    end
  end
  @score = @right / (@quiz.questions.length).to_f * 100

  erb :results
end

post '/quiz/:id/results' do
  @quiz = Quiz.find(params[:id])
  @right = 0
  @last_quiz = Response.last(@quiz.questions.length)
  @last_quiz.each do |response|
    if response.correct == true
      @right += 1
    end
  end
  @score = (@right / (@quiz.questions.length).to_f * 100)
  @result = Result.create(
    quiz_id: @quiz.id,
    score: @score)

  redirect '/my_quizzes'
end