class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_username(params[:username]).try(:authenticate, params[:password])
    if user && user.activated
      reset_session
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token
      else
        cookies[:auth_token] = user.auth_token
      end
      flash[:success] = t :loggedin
      redirect_to notes_path
    else
      if user && !user.activated
        flash.now[:danger] = t :notactivated
      else
        flash.now[:danger] = t :loginfailed
      end
      render 'new'
    end
  end

  def destroy
    # Generate a new auth token (before_save action)
    current_user.save!(validate: false) if current_user
    cookies.delete :auth_token
    reset_session
    flash[:success] = t :loggedout
    redirect_to login_path
  end
end
