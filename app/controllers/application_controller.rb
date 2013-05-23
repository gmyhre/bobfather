class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :logged_in?

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def logged_in?
    !!current_user
  end
  
  def require_login
    if !logged_in?
      session[:return_to_url] = request.url if session # robots have session turned off
      redirect_to :root, :notice => "Sign Up or Login to access Bobfather"
    end
  end
  
end
