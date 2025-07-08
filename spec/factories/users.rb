FactoryBot.define do
  factory :user do
    name { "John Doe" }
    sequence(:email) { |n| "user#{n}@example.com" }
    mobile_no { "9876543210" }
    password { "password123" }
    userable { association(:customer) }
    userable_type { "Customer" }

    trait :driver do
      sequence(:licence_no) { |n| "DRVLIC#{n.to_s.rjust(5, '0')}" }
    end
  end
end
