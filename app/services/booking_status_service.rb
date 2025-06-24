class BookingStatusService
  def self.accept(id)
    Booking.find_by(id: id)&.update(status: true)
  end

  def self.reject(id)
    Booking.find_by(id: id)&.destroy
  end

  def self.finish(id)
    Booking.find_by(id: id)&.update(ride_status: true, end_time: Time.current)
  end
end
