class UsersController < ApplicationController
  before_action :require_login, only: [:edit, :update]

  # Sign up
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.activated = false
    if @user.save
      UserMailer.registered_email(@user).deliver
      flash[:success] = t :accountcreated
      redirect_to login_path
    else
      render 'new'
    end
  end

  # Password change when logged in
  def edit
    @user = current_user
  end

  def update
    @user = current_user
    user = @user.authenticate(params[:password_old])
    if user && @user.update(change_password_params)
      cookies[:auth_token] = @user.auth_token
      flash[:success] = t :changedpassword
      redirect_to notes_path
    else
      flash.now[:danger] = t :pwdoesnotmatch unless user
      render 'edit'
    end
  end

  # E-Mail verification
  def activate
    @user = User.find_by!(username: params[:username], auth_token: params[:token], activated: false)
    @user.activated = true
    @user.save!(validate: false)
    flash[:success] = t :activated
    redirect_to login_path
  end

  def resend_activation
    @user = User.find_by!(username: params[:username], activated: false)
    UserMailer.activation_email(@user).deliver
    flash[:success] = t :activationrequested
    redirect_to login_path
  end

  # Password reset
  def forgot_password
  end

  def reset_password
    @user = User.find_by(username: params[:username], email: params[:email])
    if @user
      UserMailer.password_email(@user).deliver
      flash[:success] = t :passwordresetemail
      redirect_to login_path
    else
      flash.now[:danger] = t :accountnotfound
      render 'forgot_password'
    end
  end

  def new_password
    @user = User.find_by!(username: params[:username], auth_token: params[:token])
  end

  def update_password
    @user = User.find_by!(username: params[:username], auth_token: params[:token])
    if @user.update(change_password_params)
      flash[:success] = t :changedpassword
      redirect_to login_path
    else
      render 'new_password'
    end
  end

  # Params
  private
    def user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation)
    end

    def change_password_params
      params.require(:user).permit(:password, :password_confirmation)
    end
end
