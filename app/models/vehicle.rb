class Vehicle < ApplicationRecord
  acts_as_paranoid

  belongs_to :driver
  has_many :bookings, dependent: :destroy
  has_many :ratings, as: :rateable, dependent: :destroy
  has_and_belongs_to_many :tags
  has_one_attached :image

  validates :vehicle_type, presence:true
  validates :capacity, presence: true, numericality: { greater_than: 0 }
  validate :validate_licence_plate
  validate :validate_model


  scope :by_type, ->(type){where(vehicle_type:type)}
  scope :with_tag, ->(tag_id){joins(:tags).where(tags:{id:tag_id})}
  scope :available, ->{left_outer_joins(:bookings).where(bookings: {status:[nil,false]}).or(Vehicle.left_outer_joins(:bookings).where(bookings: {id: nil})).distinct}
  scope :with_ratings_above, ->(stars){joins(:ratings).group(:id).having('AVG(ratings.stars) >= ?', stars)}


  # before_save :assign_default_tags_if_empty
  after_destroy :destroy_attaches_image


  def self.ransackable_attributes(auth_object = nil)
    %w[id model vehicle_type driver_id licence_plate created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[driver bookings]
  end

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

  def validate_model
    if model.blank?
      errors.add(:model, "can't be blank")
    elsif model.length<2
      errors.add(:model, "atleast 2 characters long")
    end
  end

  def validate_licence_plate
    if licence_plate.blank?
      errors.add(:licence_plate, "can't be blank")
    elsif Vehicle.where.not(id: id).exists?(licence_plate: licence_plate)
      errors.add(:licence_plate, "already exists")
    elsif licence_plate !~ /\A[A-Z]{2}\d{2}[A-Z]{2}\d{4}\z/
      errors.add(:licence_plate, "format is invalid. Use format: TN67AM7867")
    end
  end


  def destroy_attaches_image
    image.purge_later if image.attached?
  end

  # def assign_default_tags_if_empty
  #   if tags.empty?
  #     tags << Tag.find_or_create_by(name: "uncategorized")
  #   end
  # end

end
