class Reward < ApplicationRecord
  belongs_to :user

  validates :points, presence:true, numericality:{only_integer:true, greater_than:0}
  validates :reward_type, presence:true, length: {minimum:3}

  scope :recent, -> {order(created_at: :desc)}
  scope :by_type, ->(type) {where(reward_type: type)}
  scope :within_days, ->(days) {where("created_at >= ?", days.days.ago)}

  before_validation :format_reward_type

  def self.ransackable_attributes(auth_object = nil)
    %w[id user_id points reward_type created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user]
  end

  private

  def format_reward_type
    self.reward_type = reward_type.to_s.strip.titleize
  end

end
