require 'rails_helper'

RSpec.describe VehiclesController, type: :controller do
  
  let(:driver) { create(:driver) }
  let(:user) { create(:user, userable: driver) }
  let(:tag) { create(:tag, name: "Luxury") }
  let(:vehicle) { create(:vehicle, driver: driver) }

  before { sign_in user }

  
  describe "index" do
    
    let!(:vehicle1) { create(:vehicle, model: "Toyota", vehicle_type: "SUV", driver: driver, tags: [tag]) }
    let!(:vehicle2) { create(:vehicle, model: "Honda", vehicle_type: "Sedan", driver: driver) }

    it "returns all vehicles when no filters" do
      get :index
      expect(assigns(:vehicles).count).to eq(2)
    end

    it "filters by vehicle_type", :aggregate_failures do
      get :index, params: { vehicle_type: "SUV" }
      expect(assigns(:vehicles)).to include(vehicle1)
      expect(assigns(:vehicles)).not_to include(vehicle2)
    end

    it "filters by tag_id", :aggregate_failures do
      get :index, params: { tag_id: tag.id }
      expect(assigns(:vehicles)).to include(vehicle1)
      expect(assigns(:vehicles)).not_to include(vehicle2)
    end

    it "searches by model", :aggregate_failures do
      get :index, params: { query: "toyota" }
      expect(assigns(:vehicles)).to include(vehicle1)
      expect(assigns(:vehicles)).not_to include(vehicle2)
    end
  end

  describe "new" do
    it "renders the new vehicle form", :aggregate_failures do
      get :new
      expect(assigns(:vehicle)).to be_a_new(Vehicle)
      expect(response).to render_template(:new)
    end
  end

  describe "create" do
    let(:valid_params) do
      {
        vehicle: {
          model: "Tesla",
          vehicle_type: "Electric",
          capacity: 4,
          licence_plate: "EV123",
          tag_ids: [tag.id]
        }
      }
    end

    it "creates a new vehicle and redirects", :aggregate_failures do
      expect {
        post :create, params: valid_params
      }.to change(Vehicle, :count).by(1)

      expect(response).to redirect_to(driver_vehicles_path)
      expect(flash[:notice]).to eq("Vehicle added successfully!")
    end

    it "renders new if invalid" do
      invalid_params = { vehicle: { model: "" } }
      post :create, params: invalid_params
      expect(response).to render_template(:new)
    end
  end

  describe "edit" do
    it "finds the vehicle and renders edit", :aggregate_failures do
      get :edit, params: { id: vehicle.id }
      expect(assigns(:vehicle)).to eq(vehicle)
      expect(response).to render_template(:edit)
    end
  end

  describe "update" do
    it "updates the vehicle and redirects", :aggregate_failures do
      patch :update, params: {
        id: vehicle.id,
        vehicle: { model: "UpdatedModel" }
      }

      expect(vehicle.reload.model).to eq("UpdatedModel")
      expect(response).to redirect_to(driver_vehicles_path)
    end

    it "renders edit on failure" do
      patch :update, params: {
        id: vehicle.id,
        vehicle: { model: "" }
      }

      expect(response).to render_template(:edit)
    end
  end

  describe "destroy" do
    context "when vehicle has active bookings" do
      before do
        create(:booking, vehicle: vehicle, status: true)
      end

      it "does not delete the vehicle", :aggregate_failures do
        delete :destroy, params: { id: vehicle.id }
        expect(response).to redirect_to(driver_vehicles_path)
        expect(flash[:alert]).to match(/Cannot delete vehicle/)
        expect(Vehicle.exists?(vehicle.id)).to be true
      end
    end

    context "when vehicle has only completed bookings" do
      before do
        create(:booking, vehicle: vehicle, ride_status: true)
      end

      it "deletes vehicle and finished bookings", :aggregate_failures do
        delete :destroy, params: { id: vehicle.id }
        expect(response).to redirect_to(driver_vehicles_path)
        expect(flash[:notice]).to match(/Vehicle and completed bookings deleted/)
        expect(Vehicle.exists?(vehicle.id)).to be false
      end
    end
  end


  describe "driver_index" do
    let!(:own_vehicle) { create(:vehicle, driver: driver, model: "OwnCar") }
    let!(:other_vehicle) { create(:vehicle, model: "OtherCar") }

    it "shows only current driver's vehicles", :aggregate_failures do
      get :driver_index
      expect(assigns(:vehicles)).to include(own_vehicle)
      expect(assigns(:vehicles)).not_to include(other_vehicle)
    end

    it "filters by model" do
      get :driver_index, params: { query: "own" }
      expect(assigns(:vehicles)).to include(own_vehicle)
    end
  end

  describe "ratings" do
    let!(:rating) { create(:rating, rateable: vehicle, user: user) }

    it "loads ratings for a vehicle" do
      get :ratings, params: { vehicle_id: vehicle.id }
      expect(assigns(:ratings)).to include(rating)
    end
  end

  describe "ride_history" do
    let!(:booking1) { create(:booking, vehicle: vehicle, ride_status: true) }
    let!(:booking2) { create(:booking, vehicle: vehicle, ride_status: false) }

    it "returns only finished bookings", :aggregate_failures do
      get :ride_history, params: { vehicle_id: vehicle.id }
      expect(assigns(:bookings)).to include(booking1)
      expect(assigns(:bookings)).not_to include(booking2)
    end
  end
end
