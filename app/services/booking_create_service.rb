class BookingCreateService
  def initialize(params, user_id)
    @params = params
    @user_id = user_id
  end

  def call
    booking = Booking.new(@params)
    booking.user_id = @user_id
    booking.booking_date = Time.current
    booking.save
    booking
  end
end
