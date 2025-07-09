class Payment < ApplicationRecord
  belongs_to :booking

  validates :payment_type, presence:true, inclusion: {in: %w[Cash Upi Card]}
  validates :payment_status, inclusion: {in:[true, false]}

  scope :successful, -> {where(payment_status:true)}
  scope :failed, -> {where(payment_status:false)}
  scope :by_type, ->(type){where(payment_type:type)}

  before_validation :format_payment_type

  def self.ransackable_attributes(auth_object = nil)
    %w[booking_id created_at id payment_status payment_type updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[booking]
  end

  private

  def format_payment_type
    self.payment_type = payment_type.to_s.strip.titleize if payment_type.present?
  end

end
