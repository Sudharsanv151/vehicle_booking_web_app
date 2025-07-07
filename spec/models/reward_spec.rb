require 'rails_helper'

RSpec.describe Reward, type: :model do
  it { should belong_to(:user) }
  it "is valid with valid attributes" do
    expect(build(:reward)).to be_valid
  end


  it "is invalid without points" do
    reward = build(:reward, points: nil)
    expect(reward).to_not be_valid
  end

  it "is invalid without reward_type" do
    reward = build(:reward, reward_type: nil)
    expect(reward).to_not be_valid
  end
end
