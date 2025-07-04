require 'rails_helper'

RSpec.describe Booking, type: :model do
  it "is valid with valid attributes" do
    expect(build(:booking)).to be_valid
  end

  it { should belong_to(:user) }
  it { should belong_to(:vehicle) }
  it { should have_one(:payment).dependent(:destroy) }
  it { should have_many(:ratings).dependent(:destroy) }


  it { should validate_presence_of(:start_location) }
  it { should validate_presence_of(:end_location) }
  it { should validate_presence_of(:start_time) }
  it { should validate_presence_of(:price) }
end
