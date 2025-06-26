class Vehicle < ApplicationRecord
  belongs_to :driver
  has_many :bookings, dependent: :destroy
  has_many :ratings, as: :rateable, dependent: :destroy
  has_and_belongs_to_many :tags
  has_one_attached :image

  validates :image, presence:true
  validates :vehicle_type, :model, :licence_plate, :capacity, presence:true
  validates :model, length: {minimum:2}
  validates :licence_plate, uniqueness:true
  validates :capacity, numericality:{only_integer:true, greater_than:0}

  scope :by_type, ->(type){where(vehicle_type:type)}
  scope :with_tag, ->(tag_id){joins(:tags).where(tags:{id:tag_id})}
  scope :available, ->{left_outer_joins(:booking).where(bookings: {status:[nil,false]})}
  scope :with_ratings_above, ->(stars){join(:ratings).group(:id).having('AVG(ratings.stars) >= ?', stars)}

  before_save :assign_default_tags_if_empty
  after_destroy :destroy_attaches_image


  def average_rating
    ratings.average(:stars)&.round(1) || "not rated yet"
  end

  def booked?
    bookings.approved.not_finished.exists?
  end

  def current_customer
    bookings.approved.not_finished.last&.user
  end


  private

  def destroy_attaches_image
    image.purge_later if image.attached?
  end

  def assign_default_tags_if_empty
    if tags.empty?
      tags << Tag.find_or_create_by(name: "uncategorized")
    end
  end

end
