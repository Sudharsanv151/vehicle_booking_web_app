class BookingStatusService
  class << self
    def accept(booking_id)
      booking = Booking.find_by(id: booking_id)
      return false unless booking

      vehicle = booking.vehicle
      return false unless vehicle

      driver_id = vehicle.driver_id
      start_time = booking.start_time

      driver_vehicle_ids = Vehicle.where(driver_id: driver_id).pluck(:id)

      conflicts = Booking.where(vehicle_id: driver_vehicle_ids, status: true)
                         .where('ABS(EXTRACT(EPOCH FROM (start_time - ?)) / 3600.0) < 1', start_time)
                         .where.not(id: booking.id)

      return false if conflicts.exists?

      booking.update(status: true)
    end

    def reject(booking_id)
      booking = Booking.find_by(id: booking_id)
      booking&.update(status: false)
      Booking.find_by(id: booking_id)&.destroy
    end

    def finish(booking_id)
      booking = Booking.find_by(id: booking_id)
      booking&.update(ride_status: true)
    end
  end
end
