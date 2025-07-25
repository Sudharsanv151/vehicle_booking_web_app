# frozen_string_literal: true

ActiveAdmin.register Rating do
  permit_params :user_id, :stars, :comments, :rateable_type, :rateable_id

  scope :all
  scope('Deleted') { |ratings| ratings.where.not(deleted_at: nil) }
  scope('Active')  { |ratings| ratings.where(deleted_at: nil) }

  filter :user
  filter :stars
  filter :rateable_type
  filter :rateable_id
  filter :created_at

  index do
    selectable_column
    id_column
    column :user
    column :stars
    column :comments
    column :rateable_type
    column :rateable_id
    column :created_at
    column :deleted_at
    actions
  end

  form do |f|
    f.inputs 'Rating Details' do
      f.input :user
      f.input :stars
      f.input :comments
      f.input :rateable_type, as: :select, collection: %w[Vehicle Booking]
      f.input :rateable_id
    end
    f.actions
  end
end
