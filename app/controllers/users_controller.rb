class UsersController < ApplicationController
  before_action :require_login, only: [:edit, :update]
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = t :accountcreated
      redirect_to login_path
    else
      render 'new'
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    user = @user.authenticate(params[:password_old])
    if user && @user.update(change_password_params)
      flash[:success] = t :changedpassword
      redirect_to notes_path
    else
      flash.now[:danger] = t :pwdoesnotmatch unless user
      render 'edit'
    end
  end

  private
    def user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation)
    end

    def change_password_params
      params.require(:user).permit(:password, :password_confirmation)
    end
end
