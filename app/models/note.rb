class Note < ApplicationRecord
  belongs_to :user
  has_many :shares, dependent: :destroy

  validates :title, length: { minimum: 4 }
  validates :text, presence: true

  before_create :generate_permalink

  def to_param
    self.permalink
  end

  def generate_permalink
    begin
      link = SecureRandom.urlsafe_base64(8)
    end while Note.exists?(permalink: link)
    self.permalink = link
  end
end
