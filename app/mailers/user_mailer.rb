class UserMailer < ActionMailer::Base
  def registered_email(user)
    @user = user
    mail(to: @user.email, subject: t(:registered_email_subject))
  end

  def activation_email(user)
    @user = user
    mail(to: @user.email, subject: t(:activation_email_subject))
  end

  def password_email(user)
    @user = user
    mail(to: @user.email, subject: t(:password_email_subject))
  end
end
