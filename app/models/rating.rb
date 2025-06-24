class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :rateable, polymorphic: true

  validates :stars, presence: true, inclusion: { in: 1..5 }
  validates :comments, presence: true, length:{minimum:2}

  scope :recent, ->{order(created_at:desc)}
  scope :by_type, ->(type){where(rateable_type:type)}

  after_create :reward_user

  private

  def reward_user
    return unless user.present? && rateable_type.present?
    
    Reward.create(
      user_id: user_id,
      points: 5,
      reward_type: "Rated #{rateable_type}"
    )
  end
end
