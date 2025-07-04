class Payment < ApplicationRecord
  belongs_to :booking

  validates :payment_type, presence:true, inclusion: {in: %w[Cash UPI Card]}
  validates :payment_status, inclusion: {in:[true, false]}

  scope :successful, -> {where(payment_status:true)}
  scope :failed, -> {where(payment_status:false)}
  scope :by_type, ->(type){where(payment_type:type)}

  before_validation :format_payment_type

  def format_payment_type
    self.payment_type=payment_type.to_s.strip.capitalize
  end

end
