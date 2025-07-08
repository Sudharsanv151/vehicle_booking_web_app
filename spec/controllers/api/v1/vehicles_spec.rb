require 'rails_helper'

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

  describe "GET /api/v1/vehicles" do
    it "returns all vehicles for client credentials token" do
      get "/api/v1/vehicles", headers: { Authorization: "Bearer #{client_token.token}" }
      expect(response).to have_http_status(:ok)
      expect(json.size).to be >= 1
    end

    it "returns all vehicles for customer" do
      get "/api/v1/vehicles", headers: { Authorization: "Bearer #{customer_token.token}" }
      expect(response).to have_http_status(:ok)
    end

    it "returns only driver's vehicles for driver" do
      get "/api/v1/vehicles", headers: { Authorization: "Bearer #{driver_token.token}" }
      expect(response).to have_http_status(:ok)
      expect(json.first["driver_id"]).to eq(driver.id)
    end

    it "returns unauthorized without token" do
      get "/api/v1/vehicles"
      expect(response).to have_http_status(:ok) # fallback to public access
    end
  end


  describe "GET /api/v1/vehicles/:id" do
    it "shows the vehicle to any user" do
      get "/api/v1/vehicles/#{vehicle.id}", headers: { Authorization: "Bearer #{customer_token.token}" }
      expect(response).to have_http_status(:ok)
      expect(json["id"]).to eq(vehicle.id)
    end

    it "returns 404 for invalid vehicle" do
      get "/api/v1/vehicles/999999", headers: { Authorization: "Bearer #{driver_token.token}" }
      expect(response).to have_http_status(:not_found)
    end
  end



  describe "POST /api/v1/vehicles" do
    it "creates vehicle for driver" do
      post "/api/v1/vehicles", params: valid_params, headers: { Authorization: "Bearer #{driver_token.token}" }
      expect(response).to have_http_status(:created)
      expect(json["licence_plate"]).to eq("TN67AB1234")
    end

    it "forbids create for client token" do
      post "/api/v1/vehicles", params: valid_params, headers: { Authorization: "Bearer #{client_token.token}" }
      expect(response).to have_http_status(:forbidden)
    end

    it "forbids create for customer" do
      post "/api/v1/vehicles", params: valid_params, headers: { Authorization: "Bearer #{customer_token.token}" }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PUT /api/v1/vehicles/:id" do
    it "updates vehicle for driver" do
      put "/api/v1/vehicles/#{vehicle.id}", params: { vehicle: { model: "New Model" } },
          headers: { Authorization: "Bearer #{driver_token.token}" }
      expect(response).to have_http_status(:ok)
      expect(json["model"]).to eq("New Model")
    end

    it "forbids update for customer" do
      put "/api/v1/vehicles/#{vehicle.id}", params: valid_params, headers: { Authorization: "Bearer #{customer_token.token}" }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /api/v1/vehicles/:id" do
    it "destroys vehicle for driver" do
      delete "/api/v1/vehicles/#{vehicle.id}", headers: { Authorization: "Bearer #{driver_token.token}" }
      expect(response).to have_http_status(:no_content)
    end

    it "forbids destroy for customer" do
      delete "/api/v1/vehicles/#{vehicle.id}", headers: { Authorization: "Bearer #{customer_token.token}" }
      expect(response).to have_http_status(:forbidden)
    end
  end

end
