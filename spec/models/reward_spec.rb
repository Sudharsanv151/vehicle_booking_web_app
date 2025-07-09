require 'rails_helper'

RSpec.describe Reward, type: :model do

  describe "associations" do
    it "belongs to user" do
      expect(described_class.reflect_on_association(:user).macro).to eq(:belongs_to)
    end
  end

  describe "validations" do

    let(:reward) { build(:reward) }

    context "points validation", :aggregate_failures do
      it "is invalid without points" do
        reward.points = nil
        expect(reward).not_to be_valid
        expect(reward.errors[:points]).to include("can't be blank")
      end

      it "is invalid if points is not number" do
        reward.points = "abc"
        expect(reward).not_to be_valid
        expect(reward.errors[:points]).to include("is not a number")
      end

      it "is invalid if points is less than or equal to zero" do
        reward.points = 0
        expect(reward).not_to be_valid
        expect(reward.errors[:points]).to include("must be greater than 0")
      end
    end

    context "reward_type validation", :aggregate_failures do
      it "is invalid without reward_type" do
        reward.reward_type = nil
        expect(reward).not_to be_valid
        expect(reward.errors[:reward_type]).to include("can't be blank")
      end

      it "is invalid if reward_type is too short" do
        reward.reward_type = "ab"
        expect(reward).not_to be_valid
        expect(reward.errors[:reward_type]).to include("is too short (minimum is 3 characters)")
      end
    end
  end

  describe "callbacks" do
    it "formats reward_type before validation" do
      reward = build(:reward, reward_type: "  welcome bonus ")
      reward.valid?
      expect(reward.reward_type).to eq("Welcome Bonus")
    end
  end

  describe "scopes" do
    let!(:r1) { create(:reward, created_at: 3.days.ago, reward_type: "Signup") }
    let!(:r2) { create(:reward, created_at: 1.day.ago, reward_type: "Bonus") }

    it "filters rewards by recent" do
      # expect(Reward.recent).to eq([r2, r1])
      expect(Reward.where(id: [r1.id, r2.id]).recent).to eq([r2, r1])
    end

    it "filters rewards by reward_type" do
      expect(Reward.by_type("Signup")).to include(r1)
      expect(Reward.by_type("Signup")).not_to include(r2)
    end

    it "returns rewards created within given number of days" do
      expect(Reward.within_days(2)).to include(r2)
      expect(Reward.within_days(2)).not_to include(r1)
    end
  end

  describe ".ransackable_attributes" do
    it "returns the correct searchable attributes", :aggregate_failures do
      expect(Reward.ransackable_attributes).to include("points", "reward_type", "user_id", "created_at", "updated_at")
    end
  end

  describe ".ransackable_associations" do
    it "includes user association" do
      expect(Reward.ransackable_associations).to include("user")
    end
  end
end
