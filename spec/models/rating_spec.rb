require 'rails_helper'

RSpec.describe Rating, type: :model do

  describe "associations" do
    it "has proper associations", :aggregate_failures do
      expect(described_class.reflect_on_association(:user).macro).to eq(:belongs_to)
      rateable_assoc = described_class.reflect_on_association(:rateable)
      expect(rateable_assoc.macro).to eq(:belongs_to)
      expect(rateable_assoc.options[:polymorphic]).to be true
    end
  end

  describe "validations" do

    let(:rating) { build(:rating) }

    context "stars validation", :aggregate_failures do
      it "is invalid without stars" do
        rating.stars = nil
        expect(rating).not_to be_valid
        expect(rating.errors[:stars]).to include("can't be blank")
      end

      it "is invalid if stars not in 1..5" do
        rating.stars = 6
        expect(rating).not_to be_valid
        expect(rating.errors[:stars]).to include("must be between 1 and 5")
      end
    end

    context "comments validation", :aggregate_failures do
      it "is invalid if no comment present" do
        rating.comments = nil
        expect(rating).not_to be_valid
        expect(rating.errors[:comments]).to include("can't be blank")
      end

      it "is invalid if comments too short" do
        rating.comments = "A"
        expect(rating).not_to be_valid
        expect(rating.errors[:comments]).to include("is too short (minimum is 2 characters)")
      end
    end
  end

  describe "scopes" do
    let!(:rating1) { create(:rating, created_at: 1.day.ago) }
    let!(:rating2) { create(:rating, created_at: Time.current) }

    it "filters ratings by ordered recent" do
      expect(Rating.recent).to eq([rating2, rating1])
    end

    it "filters ratings by rateable type" do
      vehicle = create(:vehicle)
      user = create(:user)
      vehicle_rating = create(:rating, rateable: vehicle, user: user)
      create(:rating, rateable_type: "Booking", user: user)
      
      result = Rating.by_type("Vehicle")
      expect(result).to include(vehicle_rating)
      expect(result.pluck(:rateable_type).uniq).to eq(["Vehicle"])
    end
  end

  describe "callbacks" do
    it "rewards user after rating is created" do
      user = create(:user, userable: create(:customer))
      vehicle = create(:vehicle)

      expect {
        create(:rating, user: user, rateable: vehicle)
      }.to change { Reward.count }.by(1)
    end
  end

  describe ".ransackable_attributes" do
    it "includes expected attributes", :aggregate_failures do
      attrs = Rating.ransackable_attributes
      expect(attrs).to include("stars")
      expect(attrs).to include("comments")
      expect(attrs).to include("user_id")
      expect(attrs).to include("rateable_type")
    end
  end

  describe ".ransackable_associations" do
    it "includes expected associations", :aggregate_failures do
      assocs = Rating.ransackable_associations
      expect(assocs).to include("user")
      expect(assocs).to include("rateable")
    end
  end
end
