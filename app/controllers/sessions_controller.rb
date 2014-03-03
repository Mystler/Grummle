class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_username(params[:username]).try(:authenticate, params[:password])
    if user
      reset_session
      user.generate_auth_token!
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token
      else
        cookies[:auth_token] = user.auth_token
      end
      flash[:success] = t :loggedin
      redirect_to notes_path
    else
      flash.now[:danger] = t :loginfailed
      render 'new'
    end
  end

  def destroy
    cookies.delete :auth_token
    reset_session
    flash[:success] = t :loggedout
    redirect_to login_path
  end
end
