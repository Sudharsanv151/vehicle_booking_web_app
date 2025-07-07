require 'rails_helper'

RSpec.describe Rating, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:rateable) }
  it "is valid with valid attributes" do
    expect(build(:rating)).to be_valid
  end

  it "is invalid without stars" do
    rating = build(:rating, stars: nil)
    expect(rating).to_not be_valid
  end

  it "is invalid if stars are not between 1 and 5" do
    rating = build(:rating, stars: 6)
    expect(rating).to_not be_valid
  end
end
