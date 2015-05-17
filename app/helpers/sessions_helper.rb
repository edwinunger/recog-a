helpers do

  def login(user)
    session[:user_id] = user.id
  end

  def logout
    session.clear
  end

  def current_user
    @current_user ||= User.where(id: session[:user_id]).first if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

end