FactoryBot.define do
  factory :tags_vehicle do
    association :vehicle
    association :tag
  end
end
