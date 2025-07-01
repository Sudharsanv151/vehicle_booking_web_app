ActiveAdmin.register Reward do
  
  permit_params :user_id, :points, :reward_type

  scope :all

  filter :user
  filter :points
  filter :reward_type
  filter :created_at


  index do
    selectable_column
    id_column
    column :user
    column :points
    column :reward_type
    column :created_at
    actions
  end


  form do |f|
    f.inputs 'Reward Details' do
      f.input :user
      f.input :points
      f.input :reward_type
    end
    f.actions
  end
end
