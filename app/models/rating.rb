class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :rateable, polymorphic: true

  validates :stars, presence: true, inclusion: { in: 1..5 }
  validates :comments, presence: true

  after_create :reward_user

  private

  def reward_user
    Reward.create(
      user_id: user_id,
      points: 5,
      reward_type: "Rated #{rateable_type}"
    )
  end
end
