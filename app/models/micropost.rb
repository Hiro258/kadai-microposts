class Micropost < ApplicationRecord
  belongs_to :user
  
  validates :content, presence: true, length: { maximum: 255 }
  
  #課題  
  has_many :favorites
  has_many :users, through: :favorites
end
