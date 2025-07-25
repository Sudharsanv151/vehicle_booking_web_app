# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { 'John Doe' }
    sequence(:email) { |n| "user#{n}@example.com" }
    mobile_no { '9876543210' }
    password { 'password123' }

    association :userable, factory: :customer

    trait :with_driver do
      association :userable, factory: :driver
    end
  end
end
