class Note < ActiveRecord::Base
  validates :title, length: { minimum: 5 }
  validates :text, presence: true

  belongs_to :user

  before_save :generate_permalink

  def to_param
    self.permalink
  end

  def generate_permalink
    unless self.permalink
      begin
        link = SecureRandom.urlsafe_base64
      end while Note.exists?(permalink: link)
      self.permalink = link
    end
  end
end
