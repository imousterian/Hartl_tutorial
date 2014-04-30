class UsersController < ApplicationController

  def show
    @user = User.find(params[:id]) #defining @user variable and retrivieng it from the DB
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
        sign_in @user
        # handle a successful save
        flash[:success] = "Welcome to the MiniTwitter App!"   # 'success' method comes from Bootstrap
        redirect_to @user
    else
        render 'new'
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
