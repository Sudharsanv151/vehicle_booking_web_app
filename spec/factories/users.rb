FactoryBot.define do
  factory :user do
    name { "John Doe" }
    email { Faker::Internet.email }
    mobile_no { "9876543210" }
    password { "password123" }
    userable { association(:customer) }
    userable_type { "Customer" }
  end
end
