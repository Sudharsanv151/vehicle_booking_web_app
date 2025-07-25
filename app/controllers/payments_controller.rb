# frozen_string_literal: true

class PaymentsController < ApplicationController
  before_action :set_booking, only: %i[new create]

  def new
    @payment = Payment.new
  end

  def create
    @payment = Payment.new(payment_params)
    @payment.payment_status = true

    if @payment.save
      redirect_to bookings_path, notice: 'Payment success!!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_booking
    @booking = Booking.find_by(id: params[:booking_id] || payment_params[:booking_id])
  end

  def payment_params
    params.require(:payment).permit(:booking_id, :payment_type)
  end
end
