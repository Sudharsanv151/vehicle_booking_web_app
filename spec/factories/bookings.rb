FactoryBot.define do
  factory :booking do
    association :user
    association :vehicle, factory: :vehicle_without_tag
    start_location { "Chennai" }
    end_location { "Bangalore" }
    price { 1500.0 }
    booking_date { 1.day.from_now.to_date }
    start_time { 1.day.from_now + 1.hour }
    end_time { 1.day.from_now + 3.hours }
    status { true }
    ride_status { false }
    proposed_price { nil }

    trait :pending do
      status { false }
    end

    trait :approved do
      status { true }
    end

    trait :finished do
      ride_status { true }
    end

    trait :not_finished do
      ride_status { false }
    end

    trait :upcoming do
      start_time { 3.days.from_now }
      booking_date { 3.days.from_now.to_date }
      end_time { 3.days.from_now + 2.hours }
    end

    trait :past do
      start_time { 2.days.ago }
      booking_date { 2.days.ago.to_date }
      end_time { 2.days.ago + 2.hours }
    end

    trait :negotiated do
      proposed_price { 100.0 }
    end
  end
end