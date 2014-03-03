class Note < ActiveRecord::Base
  validates :title, length: { minimum: 5 }
  validates :text, presence: true

  belongs_to :user
end
