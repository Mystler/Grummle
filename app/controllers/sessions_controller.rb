class SessionsController < ApplicationController
  def new
  end

  def create
    reset_session
    user = User.find_by_username(params[:username]).try(:authenticate, params[:password])
    if user && user.activated
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token
      else
        cookies[:auth_token] = user.auth_token
      end
      flash_message :success, t(:loggedin)
      redirect_to notes_path
    else
      if user && !user.activated
        link = ActionController::Base.helpers.link_to t(:requestactivation), resend_activation_path(username: user.username)
        flash_now :danger, "#{t :notactivated} #{link}".html_safe
      else
        flash_now :danger, t(:loginfailed)
      end
      render 'new'
    end
  end

  def destroy
    # Generate a new auth token (before_save action)
    current_user.save! if current_user
    cookies.delete :auth_token
    reset_session
    flash_message :success, t(:loggedout)
    redirect_to login_path
  end

  def create_oauth
    reset_session
    auth = Authorization.find_by provider: auth_hash['provider'], uid: auth_hash['uid']
    if auth
      user = auth.user
      if user.email != auth_hash['info']['email']
        user.email = auth_hash['info']['email']
        user.save!
      end
      flash_message :success, t(:loggedin)
    else
      user = User.find_by email: auth_hash['info']['email']
      if !user
        user = User.new username: auth_hash['info']['name'], email: auth_hash['info']['email']
        user.password = SecureRandom.urlsafe_base64
        user.activated = true
        flash_message :success, t(:oauth_usercreated)
      else
        flash_message :success, t(:oauth_connected)
      end
      user.authorizations.build provider: auth_hash['provider'], uid: auth_hash['uid']
      user.save!
    end
    cookies.permanent[:auth_token] = user.auth_token
    redirect_to notes_path
  end

  def oauth_failed
    flash_message :danger, t(:oauth_failed)
    redirect_to login_path
  end

  private
    def auth_hash
      request.env['omniauth.auth']
    end
end
