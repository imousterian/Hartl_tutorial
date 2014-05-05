class UsersController < ApplicationController
    before_action :signed_in_user, only: [:index, :edit, :update, :destroy]
    before_action :correct_user, only: [:edit, :update]
    before_action :admin_md_user, only: :destroy
    before_filter :signed_in_user_filter, only: [:new, :create]

    def index
        @users = User.paginate(page: params[:page])
    end

    def show
        @user = User.find(params[:id]) #defining @user variable and retrivieng it from the DB
        @microposts = @user.microposts.paginate(page: params[:page])
    end

    def new
        @user = User.new
    end

    def destroy
        # User.find(params[:id]).destroy
        # flash[:success] = "User deleted."
        user = User.find(params[:id])
        if (current_user? user) && (current_user.admin_md?)
            flash[:error] = "Can not delete admin account"
        else
            user.destroy
            flash[:success] = "User deleted."
        end
        redirect_to users_url
    end

    def create
        @user = User.new(user_params)
        if @user.save
            sign_in @user
            flash[:success] = "Welcome to the MiniTwitter App!"   # 'success' method comes from Bootstrap
            redirect_to @user
        else
            render 'new'
        end
    end

  def edit
    # @user = User.find(params[:id])
  end

  def update
    # @user = User.find(params[:id])
    if @user.update_attributes(user_params)
        flash[:success] = "Profile updated"
        redirect_to @user
    else
        render 'edit'
    end
  end

  private
    def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
        # require() and permit() come from Rails
    end

    def admin_md_user
        redirect_to(root_url) unless current_user.admin_md?
    end

    # before filters
    def signed_in_user
        unless signed_in?
            store_location
            redirect_to signin_url, notice: "Please sign in." unless signed_in?
        end
    end

    def correct_user
        @user = User.find(params[:id])
        redirect_to root_url unless current_user?(@user)
    end

    def signed_in_user_filter
        redirect_to root_path, notice: "Already logged in" if signed_in?
    end
end
