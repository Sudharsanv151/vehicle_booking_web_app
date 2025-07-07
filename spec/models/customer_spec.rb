require 'rails_helper'

RSpec.describe Customer, type: :model do
  it "is valid with a location" do
    expect(build(:customer)).to be_valid
  end

  it "is invalid without a location" do
    customer = build(:customer, location: nil)
    expect(customer).to_not be_valid
    expect(customer.errors[:location]).to include("can't be blank")
  end

  it { should have_one(:user) }
end
