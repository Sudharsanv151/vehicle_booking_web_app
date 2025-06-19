class PaymentsController < ApplicationController
  def new
    @booking = Booking.find_by(id: params[:booking_id])
    @payment = Payment.new
  end

  def create
    @payment = Payment.new(payment_params)
    @payment.payment_status = true

    if @payment.save
      redirect_to new_rating_path(rateable_type: "Booking", rateable_id: @payment.booking_id)
    else
      @booking = Booking.find_by(id: @payment.booking_id)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def payment_params
    params.require(:payment).permit(:booking_id, :payment_type)
  end
end