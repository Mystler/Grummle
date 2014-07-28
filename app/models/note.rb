class Note < ActiveRecord::Base
  belongs_to :user
  has_many :shared_notes, dependent: :destroy

  validates :title, length: { minimum: 5 }
  validates :text, presence: true

  before_create :generate_permalink

  def to_param
    self.permalink
  end

  def generate_permalink
    begin
      link = SecureRandom.urlsafe_base64
    end while Note.exists?(permalink: link)
    self.permalink = link
  end
end
