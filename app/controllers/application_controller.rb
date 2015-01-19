class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale
  before_action :mail_url_options
  helper_method :current_user

  def set_locale
    cookies.permanent[:loc] = params[:loc] if params[:loc]
    I18n.locale = cookies[:loc] || I18n.default_locale
  end

  def mail_url_options
    ActionMailer::Base.default_url_options = { host: request.host_with_port, protocol: request.protocol }
  end

  private
    def current_user
      @current_user ||= User.find_by(auth_token: cookies[:auth_token], activated: true) if cookies[:auth_token]
    end

    def require_login
      unless current_user
        flash_message :danger, t(:loginrequired)
        redirect_to login_path
      end
    end

    def flash_message(type, msg)
      flash[type] ||= []
      flash[type] << msg
    end

    def flash_now(type, msg)
      flash.now[type] ||= []
      flash.now[type] << msg
    end
end
