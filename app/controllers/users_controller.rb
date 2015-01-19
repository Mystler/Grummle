class UsersController < ApplicationController
  before_action :require_login, only: [:edit, :update]

  # Sign up
  def new
    @user = User.new
  end

  def create
    @user = User.new(new_user_params)
    @user.activated = false
    if @user.save
      UserMailer.registered_email(@user).deliver_now
      flash_message :success, t(:accountcreated)
      redirect_to login_path
    else
      render 'new'
    end
  end

  # Changing account information
  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if params[:user][:username] != @user.username
      if @user.update(change_username_params)
        cookies[:auth_token] = @user.auth_token
        flash_now :success, t(:usernamechanged)
      end
    end
    unless params[:user][:password].blank?
      user = @user.authenticate(params[:password_old])
      if user
        if @user.update(change_password_params)
          cookies[:auth_token] = @user.auth_token
          flash_now :success, t(:passwordchanged)
        end
      else
        flash_now :danger, t(:pwdoesnotmatch)
      end
    end
    if params[:user][:email] != @user.email
      @user.email = params[:user][:email]
      if @user.valid?
        UserMailer.change_email_email(@user).deliver_now
        flash_now :warning, t(:emailchange)
      end
    end
    render 'edit'
  end

  # E-Mail verification
  def activate
    @user = User.find_by!(username: params[:username], auth_token: params[:token], activated: false)
    @user.activated = true
    @user.save!
    flash_message :success, t(:activated)
    redirect_to login_path
  end

  def resend_activation
    @user = User.find_by!(username: params[:username], activated: false)
    UserMailer.activation_email(@user).deliver_now
    flash_message :success, t(:activationrequested)
    redirect_to login_path
  end

  def update_email
    @user = User.find_by!(username: params[:username], auth_token: params[:token])
    @user.email = params[:email]
    @user.save!
    cookies[:auth_token] = @user.auth_token
    flash_message :success, t(:emailchangeconfirmed)
    redirect_to notes_path
  end

  # Password reset
  def forgot_password
  end

  def reset_password
    @user = User.find_by(username: params[:username], email: params[:email])
    if @user
      UserMailer.password_email(@user).deliver_now
      flash_message :success, t(:passwordresetemail)
      redirect_to login_path
    else
      flash_now :danger, t(:accountnotfound)
      render 'forgot_password'
    end
  end

  def new_password
    @user = User.find_by!(username: params[:username], auth_token: params[:token])
  end

  def update_password
    @user = User.find_by!(username: params[:username], auth_token: params[:token])
    if @user.update(change_password_params)
      flash_message :success, t(:passwordchanged)
      redirect_to login_path
    else
      render 'new_password'
    end
  end

  # Params
  private
    def new_user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation)
    end

    def change_password_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def change_username_params
      params.require(:user).permit(:username)
    end
end
