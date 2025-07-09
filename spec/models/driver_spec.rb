require 'rails_helper'

RSpec.describe Driver, type: :model do

  let(:driver) { create(:driver, licence_no: " abcd123456 ") }

  describe "associations" do
      it "has proper associations", :aggregate_failures do
        expect(described_class.reflect_on_association(:user).macro).to eq(:has_one)
        expect(described_class.reflect_on_association(:vehicles).macro).to eq(:has_many)
        expect(described_class.reflect_on_association(:bookings).macro).to eq(:has_many)
      end
  end

  describe "validations" do
    it "is valid with a proper licence_no" do
      expect(driver).to be_valid
    end

    it "is invalid without licence_no" do
      driver.licence_no = nil
      expect(driver).not_to be_valid
      expect(driver.errors[:licence_no]).to include("can't be blank")
    end

    it "is invalid with short licence_no" do
      driver.licence_no = "123"
      expect(driver).not_to be_valid
    end

    it "is invalid with duplicate licence_no" do
      create(:driver, licence_no: "UNIQUE12345")
      duplicate = build(:driver, licence_no: "UNIQUE12345")
      expect(duplicate).not_to be_valid
    end
  end

  describe "scopes" do
    it "returns recent drivers in descending order" do
      old_driver = create(:driver, created_at: 3.days.ago)
      new_driver = create(:driver, created_at: 1.hour.ago)
      expect(Driver.recent).to eq([new_driver, old_driver])
    end

    it "returns drivers with bookings" do
      d1 = create(:driver)
      d2 = create(:driver)
      vehicle = create(:vehicle, driver: d1)
      create(:booking, vehicle: vehicle)

      expect(Driver.with_bookings).to include(d1)
      expect(Driver.with_bookings).not_to include(d2)
    end
  end


  describe "callbacks" do
    it "normalizes licence_no before validation" do
      driver.valid?
      expect(driver.licence_no).to eq("ABCD123456")
    end
  end
  

  describe "#name" do
    it "returns user's name if present" do
      driver = create(:driver)
      user = create(:user, userable: driver, name: "Jane Driver")

      expect(driver.name).to eq("Jane Driver")
    end

    it "returns 'undefined' if user is nil" do
      driver = create(:driver)
      allow(driver).to receive(:user).and_return(nil)

      expect(driver.name).to eq("undefined")
    end
  end

    
  describe "ransackable attributes" do
    it "includes expected searchable fields" do
      expect(Driver.ransackable_attributes).to include(
        "id", "licence_no", "created_at", "updated_at"
      )
    end
  end

  describe "ransackable associations" do
    it "includes expected associations" do
      expect(Driver.ransackable_associations).to include("user", "vehicles", "bookings")
    end
  end
end
