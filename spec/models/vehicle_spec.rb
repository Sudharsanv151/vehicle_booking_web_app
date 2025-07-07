require 'rails_helper'

RSpec.describe Vehicle, type: :model do
  describe "associations" do
    it { should belong_to(:driver) }
    it { should have_many(:bookings).dependent(:destroy) }
    it { should have_many(:ratings).dependent(:destroy) }
    it { should have_and_belong_to_many(:tags) }
    it { should validate_presence_of(:vehicle_type) }

  end
  
  describe "validations" do
    it { should validate_presence_of(:vehicle_type) }

    context "custom validations" do

      subject { build(:vehicle)}
      it "is invalid if licence_plate is blank" do
        subject.licence_plate=nil 
        expect(subject).not_to be_valid
        expect(subject.errors[:licence_plate]).to include("can't be blank")
      end

      it "is invalid if capacity is blank" do
        subject.capacity=nil 
        expect(subject).not_to be_valid
        expect(subject.errors[:capacity]).to include("can't be blank")
      end

      it "is invalid if wrong licence_plate format" do
        subject.licence_plate="INVALID123"
        expect(subject).not_to be_valid
        expect(subject.errors[:licence_plate]).to include("format is invalid, use format: TN67AM8971")
      end

      it 'is invalid if licence_plate is duplicate' do
        create(:vehicle, licence_plate: 'TN67AM7867')
        vehicle.licence_plate = 'TN67AM7867'
        vehicle.validate
        expect(vehicle.errors[:licence_plate]).to include("already exists")
      end

      it "is invalid if model is too short" do
        subject.licence_plate="I"
        expect(subject).not_to be_valid
        expect(subject.errors[:licence_plate]).to include("atleast 2 characters long")
      end

      it "is invalid if capacity is non-numeric" do
        subject.licence_plate="INVALID123"
        expect(subject).not_to be_valid
        expect(subject.errors[:licence_plate]).to include("format is invalid, use format: TN67AM8971")
      end

      it "is invalid if capacity is zero or less than zero" do
        subject.capacity=0
        expect(subject).not_to be_valid
        expect(subject.errors[:licence_plate]).to include("must be greater than 0")
      end 
    end
  end

  describe "scopes" do
    let(:driver) {create(:driver)}

    it "filters by vehicle type" do
      car = create(:vehicle,vehicle_type: "Car", driver: driver)
      bike = create(:vehicle,vehicle_type: "Bike", driver: driver)
      expect(Vehicle.by_type("Car")).to include(car)
      expect(Vehicle.by_type("Bike")).not_to include(bike)
    end
  end

  describe "#average_rating" do
    it "returns average rating in correct format" do
      vehicle = create(:vehicle)
      create(:rating,rateable: vehicle,stars: 4)
      create(:rating,rateable: vehicle,stars: 5)
      expect(vehicle.average_rating).to eq(4.5)
    end

    it "returns fallback if no ratings" do
      vehicle = create(:vehicle)
      expect(vehicle.average_rating).to eq("not rated yet")
    end
  end


  describe "#booked?" do
    it "returns true if vehicle has not booked yet" do
      vehicle = create(:vehicle)
      create(:booking,vehicle: vehicle,status: true,ride_status: false)
      expect(vehicle.booked?).to be true
    end
  end

  describe '#current_customer' do
    it 'returns user of current booking of this vehicle' do
      vehicle.save!
      booking = create(:booking, vehicle: vehicle, status: true, ride_status: false)
      expect(vehicle.current_customer).to eq(booking.user)
    end
  end


  describe "#assign_default_tags_if_empty" do
    it "adds uncategorized tag if tags not there" do
      vehicle = create(:vehicle, tags:[])
      expect(vehicle.tags.map(&:name)).to include("uncategorized")
    end
  end
end
