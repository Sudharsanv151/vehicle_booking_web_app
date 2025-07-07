ActiveAdmin.register Payment do
  permit_params :booking_id, :payment_type, :payment_status

  scope :all
  scope("Paid")     { |payments| payments.where(payment_status: true) }
  scope("Unpaid")   { |payments| payments.where(payment_status: false) }

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
end