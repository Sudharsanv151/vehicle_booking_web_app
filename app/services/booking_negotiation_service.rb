class BookingNegotiationService
  def self.propose_price(booking, driver_id, new_price)
    return false if booking.customer_accepted?
    return false unless booking&.vehicle&.driver&.id == driver_id && !booking.status

    booking.update(proposed_price: new_price)
  end

  def self.accept_price(booking, customer_id)
    return false unless booking.user_id == customer_id && !booking.status
    return false if booking.proposed_price.blank?

    booking.update(
      price: booking.proposed_price,
      customer_accepted: true,
      proposed_price: nil
    )
  end
end
