class User < ApplicationRecord
  acts_as_paranoid
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:github] 

  belongs_to :userable, polymorphic: true
  has_many :bookings, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :rewards, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :mobile_no, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :valid_mobile_no_format
  validate :validate_userable_presence

  scope :customers, -> { where(userable_type: 'Customer') }
  scope :drivers, -> { where(userable_type: 'Driver') }
  scope :with_rewards, -> { joins(:rewards).distinct }

  before_validation :normalize_email_and_mobile
  before_create :assign_welcome_reward

  
  def self.ransackable_associations(auth_object = nil)
    ["bookings", "ratings", "rewards", "userable"]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id name email mobile_no userable_type userable_id created_at updated_at]
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name   # if your user model has name
    end
  end



  def driver?
    userable_type == 'Driver'
  end

  def customer?
    userable_type == 'Customer'
  end

  def total_reward_points
    rewards.sum(:points)
  end

  private

  def normalize_email_and_mobile
    if email.blank?
      errors.add(:email, "is needed")
    end
  
    self.email = email.to_s.strip.downcase
    self.mobile_no = mobile_no.to_s.strip
  end

  def assign_welcome_reward
    return unless customer?
    rewards.build(points: 20, reward_type: "Welcome Reward Bonus")
  end

  def valid_mobile_no_format
    return if mobile_no.blank?

    unless mobile_no =~ /\A\d{10}\z/
      errors.add(:mobile_no, "must be exactly 10 digits and only numbers")
    end
  end

  def validate_userable_presence
    if userable.nil? || !(userable.is_a?(Customer) || userable.is_a?(Driver))
      errors.add(:userable, "must be assigned as a valid Customer or Driver")
    end
  end
end
