FactoryBot.define do
  factory :booking do
    association :user
    association :vehicle
    start_location { "Chennai" }
    end_location { "Bangalore" }
    price { 1500.0 }
    booking_date { Time.zone.now }
    start_time { Time.zone.now + 1.hour }
    end_time { Time.zone.now + 3.hours }
    status { false }
    ride_status {false}
  end
end
