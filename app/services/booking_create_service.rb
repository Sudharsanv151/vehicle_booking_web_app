class BookingCreateService
  def initialize(params, user)
    @params = params
    @user =user
  end

  def call
    booking = Booking.new(@params)
    booking.user=@user
    booking.booking_date = Time.current
    booking.save
    booking
  end
end
