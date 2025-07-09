FactoryBot.define do
  factory :vehicle do
    association :driver
    vehicle_type { "Car" }
    model { "Innova 2.0" }
    sequence(:licence_plate) { |n| "TN67AM#{7897 + n}" }
    capacity { 6 }

    factory :vehicle_without_tag do
      after(:create) {} # overrides parent callback to avoid tag
    end
  end
end
