require 'rails_helper'

RSpec.describe Booking, type: :model do
  describe "associations" do

    it "has proper associations", :aggregate_failures do
      expect(described_class.reflect_on_association(:user).macro).to eq(:belongs_to)
      expect(described_class.reflect_on_association(:vehicle).macro).to eq(:belongs_to)
      expect(described_class.reflect_on_association(:payment).macro).to eq(:has_one)
      expect(described_class.reflect_on_association(:ratings).macro).to eq(:has_many)
    end
  end

  describe "validations" do

    let(:user) { create(:user, userable: create(:customer)) }
    let(:vehicle) { create(:vehicle) }

    it "validates presence", :aggregate_failures do
      booking = described_class.new
      expect(booking).not_to be_valid
      expect(booking.errors[:start_location]).to include("can't be blank")
      expect(booking.errors[:end_location]).to include("can't be blank")
      expect(booking.errors[:start_time]).to include("can't be blank")
      expect(booking.errors[:price]).to include("can't be blank")
    end

    it "validates price must be greater than 50" do
      booking = build(:booking, price: 30)
      expect(booking).not_to be_valid
      expect(booking.errors[:price]).to include("must be greater than 50")
    end

    it "validates start_time not in the past" do
      booking = build(:booking, start_time: 1.hour.ago)
      expect(booking).not_to be_valid
      expect(booking.errors[:start_time]).to include("can't be in the past")
    end

    it "validates no conflicting bookings for user", :aggregate_failures do
      time=2.days.from_now
      create(:booking, user: user, start_time: time)
      conflict = build(:booking, user: user, start_time: time)
      expect(conflict).not_to be_valid
      expect(conflict.errors[:base]).to include("You already have a booking on same time")
    end
  end


  describe "scopes" do
    let!(:pending)     { create(:booking, status: false) }
    let!(:approved)    { create(:booking, status: true) }
    let!(:finished)    { create(:booking, ride_status: true) }
    let!(:not_finished){ create(:booking, ride_status: false) }
    let!(:future)      { create(:booking, start_time: 3.days.from_now) }
    # let!(:past)        { create(:booking, start_time: 2.days.ago) }
    let!(:negotiated)  { create(:booking, proposed_price: 100.0) }

    it "returns correct records", :aggregate_failures do
    

      expect(Booking.pending).to include(pending)
      expect(Booking.approved).to include(approved)
      expect(Booking.finished).to include(finished)
      expect(Booking.not_finished).to include(not_finished)
      expect(Booking.upcoming).to include(future)
      # expect(Booking.past).to include(past)
      expect(Booking.negotiated).to include(negotiated)
    end
  end

  describe "instance methods" do

    let(:booking) { build(:booking, price: 100, proposed_price: 120, customer_accepted: false) }

    it "returns final_price based on customer_accepted" do
      expect(booking.final_price).to eq(100)

      booking.customer_accepted = true
      expect(booking.final_price).to eq(120)
    end

    it "returns the driver of vehicle" do
      vehicle = create(:vehicle)
      booking = create(:booking, vehicle: vehicle)
      expect(booking.driver).to eq(vehicle.driver)
    end
  end

  describe "callbacks" do

    it "rewards customer after ride completion" do
      booking = create(:booking, ride_status: false)
      expect {
        booking.update(ride_status: true)
      }.to change { Reward.count }.by(1)
    end

    it "destroys ratings after deletion" do
      booking = create(:booking)
      create_list(:rating, 2, rateable: booking)
      expect { booking.destroy }.to change { Rating.count }.by(-2)
    end
  end


  describe ".ransackable_attributes" do
    it "returns searchable attributes" do
      expect(described_class.ransackable_attributes).to include("start_location", "status", "user_id")
    end
  end

  describe ".ransackable_associations" do
    it "includes related associations" do
      expect(described_class.ransackable_associations).to include("user", "vehicle", "ratings", "payment")
    end
  end
end
