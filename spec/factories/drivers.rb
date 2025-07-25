# frozen_string_literal: true

FactoryBot.define do
  factory :driver do
    sequence(:licence_no) { |n| "LIC#{n.to_s.rjust(11, '0')}" }
  end
end
