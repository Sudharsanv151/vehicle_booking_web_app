# frozen_string_literal: true

ActiveAdmin.register Payment do
  permit_params :booking_id, :payment_type, :payment_status

  scope :all
  scope('Paid')   { |payments| payments.where(payment_status: true) }
  scope('Unpaid') { |payments| payments.where(payment_status: false) }

  filter :booking_user_id,
         as: :select,
         label: 'Customer',
         collection: lambda {
           User.where(userable_type: 'Customer').pluck(:name, :id)
         }

  filter :booking_vehicle_id,
         as: :select,
         label: 'Vehicle',
         collection: lambda {
           Vehicle.all.map { |v| ["#{v.model} (#{v.vehicle_type})", v.id] }
         }

  filter :booking_start_location, label: 'Start Location'
  filter :booking_end_location, label: 'End Location'
  filter :booking_price, label: 'Booking Price'
  filter :booking_booking_date, label: 'Booking Date'
  filter :booking_status, as: :select, label: 'Booking Status'
  filter :booking_ride_status, as: :select, label: 'Ride Status'

  filter :booking_id
  filter :payment_type
  filter :payment_status
  filter :created_at

  index do
    selectable_column
    id_column
    column :booking
    column :payment_type
    column :payment_status
    column :created_at
    actions
  end

  form do |f|
    f.inputs 'Payment Details' do
      f.input :booking
      f.input :payment_type
      f.input :payment_status
    end
    f.actions
  end

  controller do
    def scoped_collection
      super.joins(:booking)
    end
  end
end
