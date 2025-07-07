class Driver < ApplicationRecord
  acts_as_paranoid
  
  has_one :user, as: :userable
  has_many :vehicles, dependent: :destroy
  has_many :bookings, through: :vehicles

  validates :licence_no, presence:true, uniqueness:true, length:{minimum:10}

  scope :with_bookings, ->{joins(:bookings).distinct}
  scope :recent, ->{order(created_at: :desc)}

  before_validation :normalize_licence

  def self.ransackable_associations(auth_object = nil)
    %w[bookings user vehicles]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id licence_no created_at updated_at]
  end

  def total_completed_rides
    bookings.where(ride_status:true).count
  end

  def total_earnings
    bookings.where(ride_status:true).sum(:price)
  end

  def name
    user&.name || "undefined"
  end


  private

  def normalize_licence
    self.licence_no=licence_no.to_s.strip.upcase
  end

end
