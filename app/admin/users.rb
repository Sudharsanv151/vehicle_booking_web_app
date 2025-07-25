# frozen_string_literal: true

ActiveAdmin.register User do
  permit_params :name, :email, :mobile_no

  scope :all, default: true
  scope('Customers') { |users| users.where(userable_type: 'Customer') }
  scope('Drivers')   { |users| users.where(userable_type: 'Driver') }

  filter :id
  filter :name
  filter :email
  filter :mobile_no
  filter :userable_type
  filter :created_at

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :mobile_no
    column :userable_type
    column('Extra Info') do |user|
      case user.userable_type
      when 'Customer'
        user.userable&.location
      when 'Driver'
        user.userable&.licence_no
      else
        '-'
      end
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :name
      row :email
      row :mobile_no
      row :userable_type
      row :created_at
      row :updated_at
      if user.userable_type == 'Customer'
        row('Location') { user.userable&.location || '-' }
      elsif user.userable_type == 'Driver'
        row('Licence No') { user.userable&.licence_no || '-' }
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :email
      f.input :mobile_no
      f.input :userable_type
      f.input :userable_id
    end
    f.actions
  end
end
