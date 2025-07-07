require 'rails_helper'

RSpec.describe Payment, type: :model do
   it "is valid with valid attributes" do
    expect(build(:payment)).to be_valid
  end

  it "is invalid without a booking" do
    payment = build(:payment, booking: nil)
    expect(payment).to_not be_valid
  end
  it { should belong_to(:booking) }

end
