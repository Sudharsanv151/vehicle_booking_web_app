class Rating < ApplicationRecord
  acts_as_paranoid
  
  belongs_to :user
  belongs_to :rateable, polymorphic: true

  validate :validate_stars
  validate :validate_comments

  scope :recent, ->{order(created_at: :desc)}
  scope :by_type, ->(type){where(rateable_type:type)}

  after_create :reward_user

  def self.ransackable_attributes(auth_object = nil)
    %w[comments created_at id rateable_id rateable_type stars updated_at user_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user rateable]
  end

  private

  def validate_stars
    if stars.blank?
      errors.add(:stars, "can't be blank")
    elsif !(1..5).include?(stars.to_i)
      errors.add(:stars, "must be between 1 and 5")
    end
  end


  def validate_comments
    if comments.blank?
      errors.add(:comments, "can't be blank")
    elsif comments.length < 2
      errors.add(:comments, "is too short (minimum is 2 characters)")
    end
  end


  def reward_user
    return unless user.present? && rateable_type.present?
    
    Reward.create(
      user_id: user_id,
      points: 5,
      reward_type: "Rated #{rateable_type}"
    )
  end
end
