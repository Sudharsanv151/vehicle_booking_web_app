require 'rails_helper'

RSpec.describe Tag, type: :model do
  it "is valid with a name" do
    expect(build(:tag)).to be_valid
  end

  it { should have_and_belong_to_many(:vehicles) }

  it "is invalid without a name" do
    tag = build(:tag, name: nil)
    expect(tag).to_not be_valid
    expect(tag.errors[:name]).to include("can't be blank")
  end
end
