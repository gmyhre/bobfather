class SessionsController < ApplicationController
  
  def create
    auth = request.env["omniauth.auth"]
    user = User.find(fbid: auth['uid'])
    if !user
      user = User.create(fbid: auth['uid'])      
    end    
    # doesn't hit db, no save
    user.update_from_fb_omniuath(auth)
    if user.new_registration?
      # doing this on the show page
      # user.get_fb_friends
    end
    # Rails.logger.info("\n\nFacebook User::#{user.fbid}\n")
    user.registered = true
    user.state = User::FEATUREALBE
    user.last_login = Time.now
    # log them in
    if user.save
      session[:user_id] = user.id    
    end
    redirect_to onboarding_welcome_path and return if !user.bobfather
    redirect_to onboarding_welcome_path and return
  end

  def destroy
    session[:user_id] = nil
    redirect_to :root, :notice => "successfully logged out"
  end
end
