class BobfathersController < ApplicationController
  def index
    @users = User.all
    # find the bobfather points
    @user = User.find_by_name("graham")
    @points = @user.incoming(:bobfather).depth(:all).count if @user
  end

  def new
  end

  def show
  end

  def create
    u1 = User.find(params[:u1])
    u2 = User.find(params[:u2])
    u1.bobfather = u2
    u1.bobfather_rel[:state] = 'proposed'
    respond_to do |format|
      if u1.save
        
        format.html { redirect_to bobfathers_path, notice: 'User was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  def destroy
    u1 = User.find(params[:id])
    u2 = User.find(params[:bobfather_id])
    u1.bobfather_rel.destroy
  end

  def update
  end
end
