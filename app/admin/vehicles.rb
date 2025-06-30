ActiveAdmin.register Vehicle do

  permit_params :model, :vehicle_type, :licence_plate, :driver_id

  filter :id
  filter :model
  filter :vehicle_type
  filter :licence_plate
  filter :driver
  filter :created_at

  index do
    selectable_column
    id_column
    column :model
    column :vehicle_type
    column :licence_plate
    column :driver
    actions
  end

  show do
    attributes_table do
      row :id
      row :model
      row :vehicle_type
      row :licence_plate
      row :driver
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :model
      f.input :vehicle_type
      f.input :licence_plate
      f.input :driver
    end
    f.actions
  end
end
