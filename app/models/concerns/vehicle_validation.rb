module VehicleValidation

  extend ActiveSupport::Concern

  included do
    validate :validate_capacity
    validate :validate_licence_plate
    validate :validate_model

    after_destroy :destroy_attaches_image
  end

  private

  def validate_model
    if model.blank?
      errors.add(:model, "can't be blank")
    elsif model.length < 2
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

  def validate_capacity
    if capacity.blank?
      errors.add(:capacity, "can't be blank")
    elsif !capacity.is_a?(Numeric)
      errors.add(:capacity, "is not a number")
    elsif capacity <= 0
      errors.add(:capacity, "must be greater than 0")
    end
  end

  def destroy_attaches_image
    image.purge_later if image.attached?
  end
end
