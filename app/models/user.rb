class User < ActiveRecord::Base
  has_secure_password

  validates :username, uniqueness: { case_sensitive: false }, length: { in: 3..24 }, format: { with: /\A\S+\Z/ }
  validates :email, uniqueness: { case_sensitive: false }, format: { with: /\S+@\S+\.\w+/ }
  validates :password, confirmation: true, length: { minimum: 7 }
  validates :password_confirmation, presence: true

  has_many :notes

  def generate_auth_token!
    begin
      token = SecureRandom.urlsafe_base64
    end while User.exists?(auth_token: token)
    self.auth_token = token
    self.auth_token_updated = DateTime.now
    save!(validate: false)
  end
end
