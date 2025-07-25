# frozen_string_literal: true

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

      conflicts = Booking.where(vehicle_id: driver_vehicle_ids, status: true, cancelled_by: nil)
                         .where('ABS(EXTRACT(EPOCH FROM (start_time - ?)) / 3600.0) < 1', start_time)
                         .where.not(id: booking.id)

      return false if conflicts.exists?

      booking.update(status: true)
    end

    def reject(booking_id, cancelled_by = 'driver')
      booking = Booking.find_by(id: booking_id)
      return false unless booking

      booking.update(
        status: false,
        cancelled_at: Time.current,
        cancelled_by: cancelled_by
      )
    end

    def finish(booking_id)
      booking = Booking.find_by(id: booking_id)
      return false unless booking

      booking.update_columns(ride_status: true, end_time: Time.current)
    end
  end
end
