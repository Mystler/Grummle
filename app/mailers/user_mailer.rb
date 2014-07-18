class UserMailer < ActionMailer::Base
  def registered_email(user)
    @user = user
    mail(to: @user.email, subject: '[Grummle] Account Registered')
  end
end
