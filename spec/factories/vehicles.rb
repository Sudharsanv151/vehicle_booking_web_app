FactoryBot.define do
  factory :vehicle do
    association :driver
    vehicle_type { "Car" }
    model { "Innova 2.0" }
    licence_plate { "TN67AM7897" }
    capacity { 6 }
  end
end
