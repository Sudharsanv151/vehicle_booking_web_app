class User < ApplicationRecord
  belongs_to :userable, polymorphic: true
  has_many :bookings, dependent: :destroy
  has_many :ratings ,dependent: :destroy
  has_many :rewards, dependent: :destroy

  validates :name, :email, :password, :mobile_no, presence:true
  validates :email, uniqueness:true, format:{with: URI::MailTo::EMAIL_REGEXP}
  validates :mobile_no, length:{is:10}, numericality:{only_integer:true}


  scope :customers, ->{where(userable_type:'Customer')}
  scope :drivers, ->{where(userable_type:'Driver')}
  scope :with_rewards, ->{joins(:rewards).distinct}


  before_validation :normalize_email
  before_create :assign_welcome_reward


  def driver?
    userable_type=="Driver"
  end

  def customer?
    userable_type=="Customer"
  end

  def total_reward_points
    rewards.sum(:points)
  end

  private

  def normalize_email
    self.email=email.to_s.strip.downcase
  end

  def assign_welcome_reward
    return unless customer?

    rewards.build(
      points:20,
      reward_type:"welcome reward bonus"
    )
  end

end
