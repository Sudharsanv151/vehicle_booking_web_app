class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :rateable, polymorphic: true

  validates :stars, presence:true, inclusion:{in:1..5}
  validates :comments, presence:true
end
