# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    association :booking
    payment_type { 'card' }
    payment_status { true }
  end
end
