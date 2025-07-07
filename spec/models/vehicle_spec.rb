require 'rails_helper'

RSpec.describe Vehicle, type: :model do
  describe "associations" do
    it "has proper associations", :aggregate_failures do
      expect(described_class.reflect_on_association(:driver).macro).to eq(:belongs_to)
      expect(described_class.reflect_on_association(:bookings).macro).to eq(:has_many)
      expect(described_class.reflect_on_association(:ratings).macro).to eq(:has_many)
      expect(described_class.reflect_on_association(:tags).macro).to eq(:has_and_belongs_to_many)
    end
  end


  describe "validations" do

    subject { build(:vehicle) }

    it "validates presence of vehicle_type" do
      subject.vehicle_type = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:vehicle_type]).to include("can't be blank")
    end

    context "custom validations", :aggregate_failures do
      it "validates licence_plate" do
        subject.licence_plate = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:licence_plate]).to include("can't be blank")

        create(:vehicle, licence_plate: "TN67AM7867")
        subject.licence_plate = "TN67AM7867"
        expect(subject).not_to be_valid
        expect(subject.errors[:licence_plate]).to include("already exists")

        subject.licence_plate = "INVALID123"
        expect(subject).not_to be_valid
        expect(subject.errors[:licence_plate]).to include("format is invalid. Use format: TN67AM7867")
      end

      it "validates model presence and its length" do
        subject.model = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:model]).to include("can't be blank")

        subject.model = "A"
        expect(subject).not_to be_valid
        expect(subject.errors[:model]).to include("atleast 2 characters long")
      end

      it "validates capacity presence, numeric, greater than zero" do
        subject.capacity = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:capacity]).to include("can't be blank")

        subject.capacity = "abc"
        expect(subject).not_to be_valid
        expect(subject.errors[:capacity]).to include("must be a number") 

        subject.capacity = []
        expect(subject).not_to be_valid
        expect(subject.errors[:capacity]).to include("must be a number") 

      
        subject.capacity = "123a"
        expect(subject).not_to be_valid
        expect(subject.errors[:capacity]).to include("must be a number") 

        subject.capacity = 0
        expect(subject).not_to be_valid
        expect(subject.errors[:capacity]).to include("must be greater than 0")
      end
    end
  end


  describe "scopes" do
    let(:driver) { create(:driver) }

    it "filters vehicles by type", :aggregate_failures do
      car = create(:vehicle, vehicle_type: "Car", driver: driver)
      bike = create(:vehicle, vehicle_type: "Bike", driver: driver)
      expect(Vehicle.by_type("Car")).to include(car)
      expect(Vehicle.by_type("Car")).not_to include(bike)
    end

    it "filters vehicles with specific tag" do
      tag = create(:tag)
      vehicle_with_tag = create(:vehicle, tags: [tag])
      vehicle_without_tag = create(:vehicle)
      expect(Vehicle.with_tag(tag.id)).to include(vehicle_with_tag)
      expect(Vehicle.with_tag(tag.id)).not_to include(vehicle_without_tag)
    end

    it "returns only available vehicles" do
      vehicle_no_bookings = create(:vehicle)
      vehicle_booked_active = create(:vehicle)
      create(:booking, vehicle: vehicle_booked_active, status: true) 

      vehicle_booked_status_false = create(:vehicle)
      create(:booking, vehicle: vehicle_booked_status_false, status: false)

      vehicle_booked_status_nil = create(:vehicle)
      create(:booking, vehicle: vehicle_booked_status_nil, status: nil) 

      expect(Vehicle.available).to include(vehicle_no_bookings)
      expect(Vehicle.available).to include(vehicle_booked_status_false)
      expect(Vehicle.available).to include(vehicle_booked_status_nil)
      expect(Vehicle.available).not_to include(vehicle_booked_active)
    end

    it "returns vehicles with average rating above threshold" do
      vehicle_good = create(:vehicle)
      vehicle_poor = create(:vehicle)
      create(:rating, rateable: vehicle_good, stars: 5)
      create(:rating, rateable: vehicle_poor, stars: 2)
      expect(Vehicle.with_ratings_above(4)).to include(vehicle_good)
      expect(Vehicle.with_ratings_above(4)).not_to include(vehicle_poor)
    end
  end


  describe "#average_rating" do
    it "returns average of ratings if present" do
      vehicle = create(:vehicle)
      create(:rating, rateable: vehicle, stars: 4)
      create(:rating, rateable: vehicle, stars: 5)
      expect(vehicle.average_rating).to eq(4.5)
    end

    it "returns 'not rated yet' if no ratings" do
      vehicle = create(:vehicle)
      expect(vehicle.average_rating).to eq("not rated yet")
    end
  end



  describe "#booked?" do
    it "returns true if vehicle has active booking" do
      vehicle = create(:vehicle)
      create(:booking, vehicle: vehicle, status: true, ride_status: false, approved: true)
      expect(vehicle.booked?).to be true
    end

    it "returns false if no active bookings" do
      vehicle = create(:vehicle)
      expect(vehicle.booked?).to be false
    end

    it "returns false if booking is not approved" do
      vehicle = create(:vehicle)
      create(:booking, vehicle: vehicle, status: true, ride_status: false, approved: false)
      expect(vehicle.booked?).to be false
    end

    it "returns false if booking is finished" do
      vehicle = create(:vehicle)
      create(:booking, vehicle: vehicle, status: true, ride_status: true, approved: true)
      expect(vehicle.booked?).to be false
    end
  end


  describe "#current_customer" do
    it "returns the user of the latest ongoing booking" do
      vehicle = create(:vehicle)
      user1 = create(:user)
      user2 = create(:user)
      create(:booking, vehicle: vehicle, status: true, ride_status: true, approved: true, user: user1) # finished
      booking = create(:booking, vehicle: vehicle, status: true, ride_status: false, approved: true, user: user2) # ongoing
      expect(vehicle.current_customer).to eq(booking.user)
    end

    it "returns nil if no bookings" do
      vehicle = create(:vehicle)
      expect(vehicle.current_customer).to be_nil
    end

    it "returns nil if only finished bookings" do
      vehicle = create(:vehicle)
      create(:booking, vehicle: vehicle, status: true, ride_status: true, approved: true)
      expect(vehicle.current_customer).to be_nil
    end

    it "returns nil if only unapproved bookings" do
      vehicle = create(:vehicle)
      create(:booking, vehicle: vehicle, status: true, ride_status: false, approved: false)
      expect(vehicle.current_customer).to be_nil
    end
  end


  describe "#assign_default_tags_if_empty" do
    it "adds 'uncategorized' tag if no tags are present" do
      vehicle = create(:vehicle, tags: [])
      vehicle.save!
      expect(vehicle.tags.pluck(:name)).to include("uncategorized")
    end

    it "does not add 'uncategorized' tag if tags are already present" do
      existing_tag = create(:tag, name: "Luxury")
      vehicle = create(:vehicle, tags: [existing_tag])
      vehicle.save!
      expect(vehicle.tags.pluck(:name)).to eq(["Luxury"])
    end
  end


  describe "callbacks" do
    it "purges attached image on destroy" do
      vehicle = create(:vehicle)
      file = fixture_file_upload(Rails.root.join("spec", "fixtures", "files", "test.jpg"), "image/jpeg")
      vehicle.image.attach(file)
      expect(vehicle.image).to be_attached
      vehicle.destroy
      expect(vehicle.image).not_to be_attached
    end

    it "does not purge image on destroy if no image is attached" do
      vehicle = create(:vehicle)
      expect(vehicle.image).not_to be_attached
      expect { vehicle.destroy }.not_to raise_error 
    end

    it "destroys associated bookings when vehicle is destroyed" do
      vehicle = create(:vehicle)
      booking = create(:booking, vehicle: vehicle)
      expect { vehicle.destroy }.to change(Booking, :count).by(-1)
      expect(Booking.find_by(id: booking.id)).to be_nil
    end

    it "destroys associated ratings when vehicle is destroyed" do
      vehicle = create(:vehicle)
      rating = create(:rating, rateable: vehicle)
      expect { vehicle.destroy }.to change(Rating, :count).by(-1)
      expect(Rating.find_by(id: rating.id)).to be_nil
    end

    context "acts_as_paranoid" do
      it "soft deletes the vehicle on destroy" do
        vehicle = create(:vehicle)
        vehicle.destroy
        expect(Vehicle.with_deleted.find_by(id: vehicle.id)).to be_present
        expect(Vehicle.find_by(id: vehicle.id)).to be_nil 
        expect(vehicle.deleted_at).to be_present
      end
    end
  end


  describe ".ransackable_attributes" do
    it "returns correct searchable attributes" do
      expect(Vehicle.ransackable_attributes).to include("vehicle_type", "model", "licence_plate", "id", "driver_id", "created_at", "updated_at")
    end
  end


  describe ".ransackable_associations" do
    it "returns correct searchable associations" do
      expect(Vehicle.ransackable_associations).to include("driver", "bookings")
    end
  end


end
