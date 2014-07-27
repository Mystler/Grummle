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
      UserMailer.registered_email(@user).deliver
      flash[:success] = t :accountcreated
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
    user = @user.authenticate(params[:password_old])
    if user
      if !params[:user][:password].blank? && @user.update(change_password_params)
        cookies[:auth_token] = @user.auth_token
        flash.now[:success] = t :passwordchanged
      end
      if params[:user][:email] != @user.email
        @user.email = params[:user][:email]
        if @user.valid?
          UserMailer.change_email_email(@user).deliver
          flash.now[:warning] = t :emailchange
        end
      end
    else
      flash.now[:danger] = t :pwdoesnotmatch
    end
    render 'edit'
  end

  # E-Mail verification
  def activate
    @user = User.find_by!(username: params[:username], auth_token: params[:token], activated: false)
    @user.activated = true
    @user.save!
    flash[:success] = t :activated
    redirect_to login_path
  end

  def resend_activation
    @user = User.find_by!(username: params[:username], activated: false)
    UserMailer.activation_email(@user).deliver
    flash[:success] = t :activationrequested
    redirect_to login_path
  end

  def update_email
    @user = User.find_by!(username: params[:username], auth_token: params[:token])
    @user.email = params[:email]
    @user.save!
    cookies[:auth_token] = @user.auth_token
    flash[:success] = t :emailchangeconfirmed
    redirect_to notes_path
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
    def new_user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation)
    end

    def change_password_params
      params.require(:user).permit(:password, :password_confirmation)
    end
end
