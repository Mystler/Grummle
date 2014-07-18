class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale
  before_filter :mail_url_options
  helper_method :current_user

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options={})
    { locale: I18n.locale }
  end

  def mail_url_options
    ActionMailer::Base.default_url_options = {host: request.host_with_port, protocol: request.protocol, locale: I18n.locale}
  end

  private
    def current_user
      @current_user ||= User.find_by(auth_token: cookies[:auth_token], activated: true) if cookies[:auth_token]
    end

    def require_login
      unless current_user
        flash[:danger] = t :loginrequired
        redirect_to login_path
      end
    end
end
