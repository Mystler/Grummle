class User < ActiveRecord::Base
  has_secure_password
  has_many :notes, dependent: :destroy
  has_many :shares, dependent: :destroy
  has_many :authorizations, dependent: :destroy

  validates :username, uniqueness: { case_sensitive: false }, length: { in: 3..70 }
  validates :email, uniqueness: { case_sensitive: false }, format: { with: /\S+@\S+\.\w+/ }
  validates :password, length: { minimum: 7 }, allow_nil: true

  before_save :generate_auth_token

  def generate_auth_token
    begin
      token = SecureRandom.urlsafe_base64
    end while User.exists?(auth_token: token)
    self.auth_token = token
    self.auth_token_updated = DateTime.now
  end
end
