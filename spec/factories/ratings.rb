FactoryBot.define do
  factory :rating do
    association :user
    association :rateable, factory: :vehicle
    stars { 4 }
    comments { "Great ride!" }
  end
end
