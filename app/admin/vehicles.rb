ActiveAdmin.register Vehicle do
  permit_params :name, :vehicle_type, :driver_id, :license_plate

  index do
    selectable_column
    id_column
    column :name
    column :vehicle_type
    column :driver
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :vehicle_type
      f.input :driver
      f.input :license_plate
    end
    f.actions
  end
end
