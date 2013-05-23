class WelcomeController < ApplicationController
  before_filter :require_login, :only => [:onboarding]
  
  def index
    if logged_in?
      @user = current_user
    end
    @users = User.find(:all, :conditions => {:state => User::FEATUREALBE})
    # if @first_user
    #   @nodes = @first_user.incoming(:bobfather).depth(:all)
    # end
    #@users = User.find(:all)
    #2.times do |t|
    #  @users << users.shuffle
    #end
  end

  def onboarding
    @user = current_user
  end

end
