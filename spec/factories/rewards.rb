# frozen_string_literal: true

FactoryBot.define do
  factory :reward do
    association :user
    points { 10 }
    reward_type { 'discount' }
  end
end
