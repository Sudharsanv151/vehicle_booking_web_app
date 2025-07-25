# frozen_string_literal: true

ActiveAdmin.register Tag do
  permit_params :name

  scope :all

  filter :name
  filter :created_at

  index do
    selectable_column
    id_column
    column :name
    column :created_at
    actions
  end

  form do |f|
    f.inputs 'Tag Details' do
      f.input :name
    end
    f.actions
  end
end
