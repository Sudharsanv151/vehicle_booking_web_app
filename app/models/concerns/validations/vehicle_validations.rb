module Validations
  module VehicleValidations
    extend ActiveSupport::Concern

    included do
      validates :vehicle_type, presence: true
      validates :capacity, presence: true, numericality: { greater_than: 0 }
      validate :validate_licence_plate
      validate :validate_model
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
  end
end
