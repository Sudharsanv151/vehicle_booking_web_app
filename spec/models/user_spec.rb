require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with valid attributes" do
    expect(build(:user)).to be_valid
  end

  it { should belong_to(:userable) }
  it { should validate_presence_of(:email) }
end
