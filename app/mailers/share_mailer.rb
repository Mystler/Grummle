class ShareMailer < ActionMailer::Base
  def note_shared_email(note, user)
    @note = note
    @user = user
    mail(to: user.email, subject: t(:note_shared_email_subject))
  end
end
