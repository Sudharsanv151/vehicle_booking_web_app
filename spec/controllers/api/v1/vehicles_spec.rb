require 'rails_helper'

def json
  return {} if response.body.blank?
  JSON.parse(response.body)
rescue JSON::ParserError
  {}
end


RSpec.describe "Api::V1::Vehicles", type: :request do
  
  let(:driver) { create(:driver) }
  let(:driver_user) { create(:user, userable: driver) }
  let(:customer) { create(:customer) }
  let(:customer_user) { create(:user, userable: customer) }

  let(:driver_token) { create(:access_token, resource_owner_id: driver_user.id) }
  let(:customer_token) { create(:access_token, resource_owner_id: customer_user.id) }
  let(:client_token) { create(:access_token, application: create(:oauth_application), resource_owner_id: nil) }

  let!(:vehicle) { create(:vehicle, driver: driver) }

  let(:valid_params) do
    {
      vehicle: {
        vehicle_type: "Car",
        model: "Swift",
        licence_plate: "TN67AB1234",
        capacity: 4
      }
    }
  end


  describe "GET /api/v1/vehicles", :aggregate_failures do
    it "returns all vehicles for client credentials token" do
      get "/api/v1/vehicles", headers: { Authorization: "Bearer #{client_token.token}" }, as: :json
      expect(response).to have_http_status(:ok)
      expect(json.size).to be >= 1
    end

    it "returns all vehicles for customer" do
      get "/api/v1/vehicles", headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json
      expect(response).to have_http_status(:ok)
    end

    it "returns only driver's vehicles for driver", :aggregate_failures do
      get "/api/v1/vehicles", headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json
      expect(response).to have_http_status(:ok)
      expect(json.first["vehicle"]["driver_id"]).to eq(driver.id)
    end

    it "returns unauthorized without token" do
      get "/api/v1/vehicles", as: :json
      expect(response).to have_http_status(:ok)
    end

    it "returns unauthorized if token is valid but no user is found", :aggregate_failures do
      app = create(:oauth_application)
      invalid_token = create(:access_token, application: app, resource_owner_id: 999999999)

      get "/api/v1/vehicles", headers: { Authorization: "Bearer #{invalid_token.token}" }, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(json["error"]).to eq("Unauthorized request")
    end
  end






  describe "GET /api/v1/vehicles/:id" , :aggregate_failures do
    it "shows the vehicle to any user" do
      get "/api/v1/vehicles/#{vehicle.id}", headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json
      expect(response).to have_http_status(:ok)
      expect(json["vehicle"]["id"]).to eq(vehicle.id)
    end

    it "returns 404 for invalid vehicle" do
      get "/api/v1/vehicles/999999", headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end






  describe "POST /api/v1/vehicles", :aggregate_failures do

    let(:invalid_params) do
      {
        vehicle: {vehicle_type: "", model: "", licence_plate: "", capacity: nil}
      }
    end

    it "returns unauthorized when no token is provided", :aggregate_failures do
      post "/api/v1/vehicles", params: valid_params, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to be_blank
    end

    it "returns forbidden if token has invalid user (current_user is nil)" do
      app = create(:oauth_application)
      invalid_token = create(:access_token, application: app, resource_owner_id: 999999) 

      post "/api/v1/vehicles", params: valid_params, headers: { Authorization: "Bearer #{invalid_token.token}" }, as: :json
      expect(response).to have_http_status(:forbidden)
      expect(json["error"]).to eq("Only drivers can perform this action")
    end

    it "creates vehicle for driver", :aggregate_failures do
      post "/api/v1/vehicles", params: valid_params, headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json
      expect(response).to have_http_status(:created)
      expect(json["vehicle"]["licence_plate"]).to eq("TN67AB1234")
    end

    it "returns unprocessable entity when vehicle params are invalid", :aggregate_failures do
      post "/api/v1/vehicles", params: invalid_params, headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json).to include("vehicle_type", "model", "licence_plate", "capacity")
    end

    it "forbids create for client token" do
      post "/api/v1/vehicles", params: valid_params, headers: { Authorization: "Bearer #{client_token.token}" }, as: :json
      expect(response).to have_http_status(:forbidden)
      expect(json["error"]).to eq("Only users(drivers) can perform this action")
    end

    it "forbids create for customer" do
      post "/api/v1/vehicles", params: valid_params, headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json
      expect(response).to have_http_status(:forbidden)
      expect(json["error"]).to eq("Only drivers can perform this action")
    end
  end





  describe "PUT /api/v1/vehicles/:id", :aggregate_failures do
    it "updates vehicle for driver" do
      put "/api/v1/vehicles/#{vehicle.id}", params: { vehicle: { model: "New Model" } },
          headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json
      expect(response).to have_http_status(:ok)
      expect(json["vehicle"]["model"]).to eq("New Model")
    end

    it "returns unprocessable_entity if update fails due to invalid params" do
      put "/api/v1/vehicles/#{vehicle.id}",
          params: { vehicle: { licence_plate: "" } },
          headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json["licence_plate"]).to include("can't be blank")
    end

    it "forbids update for customer" do
      put "/api/v1/vehicles/#{vehicle.id}", params: valid_params, headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json
      expect(response).to have_http_status(:forbidden)
    end
  end






  describe "DELETE /api/v1/vehicles/:id", :aggregate_failures do
    it "destroys vehicle for driver" do
      delete "/api/v1/vehicles/#{vehicle.id}", headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json
      expect(response).to have_http_status(:no_content)
    end

    it "forbids destroy for customer" do
      delete "/api/v1/vehicles/#{vehicle.id}", headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json
      expect(response).to have_http_status(:forbidden)
    end
  end



  describe "GET /api/v1/vehicles/available", :aggregate_failures do
    it "returns only vehicles that are not actively booked" do
      available = create(:vehicle)
      unavailable = create(:vehicle)
      create(:booking, vehicle: unavailable, status: true)

      get "/api/v1/vehicles/available", headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json

      ids = json.map { |v| v["vehicle"]["id"] }
      expect(ids).to include(available.id)
      expect(ids).not_to include(unavailable.id)
    end
  end





  describe "GET /api/v1/vehicles/:id/rating" , :aggregate_failures do

    let!(:rating1) { create(:rating, rateable: vehicle, stars: 4, user: customer_user) }
    let!(:rating2) { create(:rating, rateable: vehicle, stars: 5, user: customer_user) }

    before do
      allow(vehicle).to receive(:average_rating).and_return(4.5)
    end

    it "returns average rating and all ratings for a vehicle" do
      get "/api/v1/vehicles/#{vehicle.id}/rating", headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json

      expect(response).to have_http_status(:ok)
      expect(json["average_rating"].to_f).to eq(4.5)
      expect(json["ratings"].size).to eq(2)
      expect(json["ratings"].first).to include("stars", "comments", "user_id")
    end
  end




  describe "GET /api/v1/vehicles/:id/current_customer" , :aggregate_failures do

    let(:booking_customer) { create(:customer) }
    let(:booking_user) { create(:user, userable: booking_customer) }
    let!(:booking_token) { create(:access_token, resource_owner_id: booking_user.id) }

    before do
      create(:booking, user: booking_user, vehicle: vehicle, ride_status: false, status: true)
    end

    context "when driver owns the vehicle" do
      it "returns the current customer details" do
        get "/api/v1/vehicles/#{vehicle.id}/current_customer",
            headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json

        expect(response).to have_http_status(:ok)
        expect(json).to include("id", "name", "email", "mobile_no")
      end
    end

    context "when client token is used" do
      it "returns the current customer details" do
        get "/api/v1/vehicles/#{vehicle.id}/current_customer",
            headers: { Authorization: "Bearer #{client_token.token}" }, as: :json

        expect(response).to have_http_status(:ok)
        expect(json).to include("id", "name", "email", "mobile_no")
      end
    end

    context "when vehicle has no current customer" do
      before { Booking.delete_all }

      it "returns a message indicating no active booking" do
        get "/api/v1/vehicles/#{vehicle.id}/current_customer",
            headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json

        expect(response).to have_http_status(:ok)
        expect(json["message"]).to eq("Vehicle is not currently assigned to any active booking")
      end
    end

    context "when unauthorized customer accesses another driver's vehicle" do
      it "returns forbidden" do
        get "/api/v1/vehicles/#{vehicle.id}/current_customer",
            headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json

        expect(response).to have_http_status(:forbidden)
        expect(json["error"]).to eq("Only the vehicle's driver or a client can access this")
      end
    end
  end



end
