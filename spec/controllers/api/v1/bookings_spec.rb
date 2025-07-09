require 'rails_helper'

def json
  return {} if response.body.blank?
  JSON.parse(response.body)
rescue JSON::ParserError
  {}
end

RSpec.describe "Api::V1::BookingsController", type: :request do
  let(:customer) { create(:customer) }
  let(:customer_user) { create(:user, userable: customer) }
  let(:driver) { create(:driver) }
  let(:driver_user) { create(:user, userable: driver) }
  let(:vehicle) { create(:vehicle, driver: driver) }
  let(:booking) { create(:booking, user: customer_user, vehicle: vehicle) }

  let(:customer_token) { create(:access_token, resource_owner_id: customer_user.id) }
  let(:driver_token) { create(:access_token, resource_owner_id: driver_user.id) }
  let(:client_token) { create(:access_token, application: create(:oauth_application), resource_owner_id: nil) }

  describe "GET /api/v1/bookings" do
    it "returns all bookings for client token" do
      get "/api/v1/bookings", headers: { Authorization: "Bearer #{client_token.token}" }, as: :json
      expect(response).to have_http_status(:ok)
    end

    it "returns customer bookings" do
      get "/api/v1/bookings", headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json
      expect(response).to have_http_status(:ok)
    end

    it "returns driver bookings" do
      get "/api/v1/bookings", headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json
      expect(response).to have_http_status(:ok)
    end

    it "returns unauthorized without token" do
      get "/api/v1/bookings", as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end





  describe "GET /api/v1/bookings/:id" do
    it "shows booking for customer" do
      get "/api/v1/bookings/#{booking.id}", headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json
      expect(response).to have_http_status(:ok)
    end

    it "shows booking for driver" do
      get "/api/v1/bookings/#{booking.id}", headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json
      expect(response).to have_http_status(:ok)
    end
  end





  describe "POST /api/v1/bookings", :aggregate_failures do
    let(:vehicle) { create(:vehicle) }

    let(:customer) { create(:customer) }
    let(:customer_user) { create(:user, userable: customer) }
    let(:customer_token) { create(:access_token, resource_owner_id: customer_user.id, scopes: "public") }

    let(:driver) { create(:driver) }
    let(:driver_user) { create(:user, userable: driver) }
    let(:driver_token) { create(:access_token, resource_owner_id: driver_user.id, scopes: "public") }

    let(:client_token) { create(:access_token, application: create(:oauth_application), resource_owner_id: nil, scopes: "") }

    let(:valid_params) do
      {
        booking: {
          vehicle_id: vehicle.id,
          start_location: "Erode",
          end_location: "Tirupur",
          price: 1000,
          booking_date: Time.current + 2.days,
          start_time: Time.current + 3.days
        }
      }
    end

    it "creates booking for customer" do
      post "/api/v1/bookings",
          params: valid_params,
          headers: { Authorization: "Bearer #{customer_token.token}" },
          as: :json

      expect(response).to have_http_status(:created), -> { "Response: #{response.body}" }
      expect(json["booking"]["vehicle_id"]).to eq(vehicle.id)
      expect(json["booking"]["start_location"]).to eq("Erode")
    end

    it "forbids booking creation for driver" do
      post "/api/v1/bookings",
          params: valid_params,
          headers: { Authorization: "Bearer #{driver_token.token}" },
          as: :json

      expect(response).to have_http_status(:forbidden)
      expect(json["error"]).to eq("You are not authorized to perform this action")
    end

    it "forbids booking creation for client" do
      post "/api/v1/bookings",
          params: valid_params,
          headers: { Authorization: "Bearer #{client_token.token}" },
          as: :json

      expect(response).to have_http_status(:forbidden)
      expect(json["error"]).to eq("Client credentials token cannot access this resource")
    end

    it "returns unprocessable entity for missing required fields" do
      post "/api/v1/bookings",
          params: { booking: { vehicle_id: nil } },
          headers: { Authorization: "Bearer #{customer_token.token}" },
          as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json).not_to have_key("vehicle_id")
    end
  end





  describe "PUT /api/v1/bookings/:id" , :aggregate_failures do

    let(:driver) { create(:driver) }
    let(:driver_user) { create(:user, userable: driver) }
    let(:vehicle) { create(:vehicle, driver: driver) }
    let(:customer) { create(:customer) }
    let(:customer_user) { create(:user, userable: customer) }
    let(:booking) { create(:booking, user: customer_user, vehicle: vehicle) }

    let(:driver_token) { create(:access_token, resource_owner_id: driver_user.id, scopes: "public") }
    let(:customer_token) { create(:access_token, resource_owner_id: customer_user.id, scopes: "public") }

    let(:params) do
      {
        booking: {
          status: true,
          ride_status: true,
          start_time: Time.current + 1.hour,
          end_time: Time.current + 2.hours
        }
      }
    end

    it "updates booking for driver" do
      put "/api/v1/bookings/#{booking.id}", params: params,
          headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json

      expect(response).to have_http_status(:ok), -> { "Error: #{response.body}" }
      expect(json["booking"]["status"]).to eq(true)
    end

    it "returns 422 if update fails due to invalid data" do
      invalid_params = {
        booking: {
          status: true,
          ride_status: true,
          start_time: nil,
          end_time: Time.current + 1.hour 
        }
      }

      put "/api/v1/bookings/#{booking.id}", params: invalid_params,
          headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json["errors"]).not_to be_empty
    end

    it "forbids booking update for customer" do
      put "/api/v1/bookings/#{booking.id}", params: params,
          headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json

      expect(response).to have_http_status(:forbidden)
    end
  end







  describe "GET /api/v1/bookings/ongoing" , :aggregate_failures do

    let(:driver) { create(:driver) }
    let(:user) { create(:user, userable: driver) }
    let(:vehicle) { create(:vehicle, driver: driver) }
    let(:booking) { create(:booking, vehicle: vehicle, status: true, ride_status: false) }
    let(:token) { create(:access_token, resource_owner_id: user.id, scopes: "public") }
    it "returns ongoing bookings for customer" do
      create(:booking, user: customer_user, vehicle: vehicle, status: true, ride_status: false)
      get "/api/v1/bookings/ongoing", headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json
      expect(response).to have_http_status(:ok)
    end

    it "returns ongoing bookings for the driver" do
      booking 

      get "/api/v1/bookings/ongoing",
        headers: { Authorization: "Bearer #{token.token}" }, as: :json
      puts response.body
      expect(response).to have_http_status(:ok)
      expect(json).to be_an(Array)
      expect(json.size).to eq(1)
      expect(json.first["booking"]["id"]).to eq(booking.id)
    end

  end





  describe "GET /api/v1/bookings/pending" do
    it "returns pending bookings for driver" do
      create(:booking, user: customer_user, vehicle: vehicle, status: false)
      get "/api/v1/bookings/pending", headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json
      expect(response).to have_http_status(:ok)
    end
  end




  describe "GET /api/v1/bookings/:id/customer_info", :aggregate_failures do
    it "returns customer info for driver" do
      get "/api/v1/bookings/#{booking.id}/customer_info", headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json
      expect(response).to have_http_status(:ok)
      expect(json).to include("id", "email", "mobile_no")
    end

    it "forbids customer_info for customer" do
      get "/api/v1/bookings/#{booking.id}/customer_info", headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json
      expect(response).to have_http_status(:forbidden)
    end
  end
end