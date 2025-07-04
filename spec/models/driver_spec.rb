require 'rails_helper'

RSpec.describe Driver, type: :model do
  it "is valid with valid attributes" do
    expect(build(:driver)).to be_valid
  end

  it { should have_many(:vehicles) }
end
