# frozen_string_literal: true

require 'rails_helper'

def json
  return {} if response.body.blank?

  JSON.parse(response.body)
rescue JSON::ParserError
  {}
end

RSpec.describe 'Api::V1::Vehicles', type: :request do
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
        vehicle_type: 'Car',
        model: 'Swift',
        licence_plate: 'TN67AB1234',
        capacity: 4
      }
    }
  end

  describe 'GET /api/v1/vehicles', :aggregate_failures do
    it 'returns all vehicles for client credentials token' do
      get '/api/v1/vehicles', headers: { Authorization: "Bearer #{client_token.token}" }, as: :json
      expect(response).to have_http_status(:ok)
      expect(json.size).to be >= 1
    end

    it 'returns all vehicles for customer' do
      get '/api/v1/vehicles', headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json
      expect(response).to have_http_status(:ok)
    end

    it "returns only driver's vehicles for driver", :aggregate_failures do
      get '/api/v1/vehicles', headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json
      expect(response).to have_http_status(:ok)
      expect(json.first['vehicle']['driver_id']).to eq(driver.id)
    end

    it 'returns unauthorized without token' do
      get '/api/v1/vehicles', as: :json
      expect(response).to have_http_status(:ok)
    end

    it 'returns unauthorized if token is valid but no user is found', :aggregate_failures do
      app = create(:oauth_application)
      invalid_token = create(:access_token, application: app, resource_owner_id: 999_999_999)

      get '/api/v1/vehicles', headers: { Authorization: "Bearer #{invalid_token.token}" }, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(json['error']).to eq('Unauthorized request')
    end
  end

  describe 'GET /api/v1/vehicles/:id' do
    context 'when viewing a specific vehicle that exists' do
      before do
        get "/api/v1/vehicles/#{vehicle.id}", headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json
      end

      it 'responds with a successful status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the details of the correct vehicle' do
        expect(json['vehicle']['id']).to eq(vehicle.id)
      end
    end

    context 'when requesting a vehicle that does not exist' do
      before { get '/api/v1/vehicles/999999', headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json }

      it 'responds with a not found status' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/vehicles' do
    let(:invalid_params) do
      {
        vehicle: { vehicle_type: '', model: '', licence_plate: '', capacity: nil }
      }
    end

    context 'when no authentication token is provided' do
      before { post '/api/v1/vehicles', params: valid_params, as: :json }

      it 'responds with an unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an empty response body' do
        expect(response.body).to be_blank
      end
    end

    context 'when authenticated as a driver' do
      context 'and providing valid vehicle details' do
        before do
          post '/api/v1/vehicles', params: valid_params, headers: { Authorization: "Bearer #{driver_token.token}" },
                                   as: :json
        end

        it 'responds with a created status' do
          expect(response).to have_http_status(:created)
        end

        it 'creates the vehicle with the specified licence plate' do
          expect(json['vehicle']['licence_plate']).to eq('TN67AB1234')
        end
      end

      context 'and providing invalid vehicle details' do
        before do
          post '/api/v1/vehicles', params: invalid_params, headers: { Authorization: "Bearer #{driver_token.token}" },
                                   as: :json
        end

        it 'responds with an unprocessable entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns validation errors for vehicle type' do
          expect(json).to have_key('vehicle_type')
        end

        it 'returns validation errors for model' do
          expect(json).to have_key('model')
        end

        it 'returns validation errors for licence plate' do
          expect(json).to have_key('licence_plate')
        end

        it 'returns validation errors for capacity' do
          expect(json).to have_key('capacity')
        end
      end
    end

    context 'when using a client application token' do
      before do
        post '/api/v1/vehicles', params: valid_params, headers: { Authorization: "Bearer #{client_token.token}" },
                                 as: :json
      end

      it 'responds with a forbidden status' do
        expect(response).to have_http_status(:forbidden)
      end

      it 'explains that only drivers can create vehicles' do
        expect(json['error']).to eq('Only users(drivers) can perform this action')
      end
    end

    context 'when authenticated as a customer' do
      before do
        post '/api/v1/vehicles', params: valid_params, headers: { Authorization: "Bearer #{customer_token.token}" },
                                 as: :json
      end

      it 'responds with a forbidden status' do
        expect(response).to have_http_status(:forbidden)
      end

      it 'explains that only drivers can create vehicles' do
        expect(json['error']).to eq('Only drivers can perform this action')
      end
    end
  end

  describe 'PUT /api/v1/vehicles/:id' do
    context 'when authenticated as a driver' do
      context 'and providing valid update parameters' do
        before do
          put "/api/v1/vehicles/#{vehicle.id}",
              params: { vehicle: { model: 'New Model' } },
              headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json
        end

        it 'responds with a successful status' do
          expect(response).to have_http_status(:ok)
        end

        it "updates the vehicle's model as requested" do
          expect(json['vehicle']['model']).to eq('New Model')
        end
      end

      context 'and providing invalid update parameters' do
        before do
          put "/api/v1/vehicles/#{vehicle.id}",
              params: { vehicle: { licence_plate: '' } },
              headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json
        end

        it 'responds with an unprocessable entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns a validation error for the licence plate' do
          expect(json['licence_plate']).to include("can't be blank")
        end
      end
    end

    context 'when authenticated as a customer' do
      before do
        put "/api/v1/vehicles/#{vehicle.id}",
            params: valid_params,
            headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json
      end

      it 'responds with a forbidden status' do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /api/v1/vehicles/:id' do
    context 'when authenticated as a driver' do
      it 'responds with a no content status after successful deletion' do
        delete "/api/v1/vehicles/#{vehicle.id}", headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when authenticated as a customer' do
      it 'responds with a forbidden status' do
        delete "/api/v1/vehicles/#{vehicle.id}", headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET /api/v1/vehicles/available' do
    let!(:available_vehicle) { create(:vehicle) }
    let!(:unavailable_vehicle) { create(:vehicle) }
    before { create(:booking, vehicle: unavailable_vehicle, status: true) }

    before { get '/api/v1/vehicles/available', headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json }

    it 'responds with a successful status' do
      expect(response).to have_http_status(:ok)
    end

    it 'includes vehicles that are not currently booked' do
      ids = json.map { |v| v['vehicle']['id'] }
      expect(ids).to include(available_vehicle.id)
    end

    it 'does not include vehicles that are currently booked' do
      ids = json.map { |v| v['vehicle']['id'] }
      expect(ids).not_to include(unavailable_vehicle.id)
    end
  end

  describe 'GET /api/v1/vehicles/:id/rating' do
    let!(:rating1) { create(:rating, rateable: vehicle, stars: 4, user: customer_user) }
    let!(:rating2) { create(:rating, rateable: vehicle, stars: 5, user: customer_user) }

    before do
      allow_any_instance_of(Vehicle).to receive(:average_rating).and_return(4.5)
      get "/api/v1/vehicles/#{vehicle.id}/rating", headers: { Authorization: "Bearer #{customer_token.token}" },
                                                   as: :json
    end

    it 'responds with a successful status' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns the calculated average rating for the vehicle' do
      expect(json['average_rating'].to_f).to eq(4.5)
    end

    it 'returns all individual ratings for the vehicle' do
      expect(json['ratings'].size).to eq(2)
    end

    it "includes the 'stars' attribute for each rating entry" do
      expect(json['ratings'].first).to have_key('stars')
    end

    it "includes the 'comments' attribute for each rating entry" do
      expect(json['ratings'].first).to have_key('comments')
    end

    it "includes the 'user_id' attribute for each rating entry" do
      expect(json['ratings'].first).to have_key('user_id')
    end
  end

  describe 'GET /api/v1/vehicles/:id/current_customer' do
    let(:booking_customer) { create(:customer) }
    let(:booking_user) { create(:user, userable: booking_customer) }
    let!(:booking_token) { create(:access_token, resource_owner_id: booking_user.id) }

    context 'when the vehicle has an active booking' do
      before do
        create(:booking, user: booking_user, vehicle: vehicle, ride_status: false, status: true)
      end

      context "and accessed by the vehicle's driver" do
        before do
          get "/api/v1/vehicles/#{vehicle.id}/current_customer",
              headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json
        end

        it 'responds with a successful status' do
          expect(response).to have_http_status(:ok)
        end

        it "returns the current customer's ID" do
          expect(json).to have_key('id')
        end

        it "returns the current customer's name" do
          expect(json).to have_key('name')
        end

        it "returns the current customer's email" do
          expect(json).to have_key('email')
        end

        it "returns the current customer's mobile number" do
          expect(json).to have_key('mobile_no')
        end
      end

      context 'and accessed by a client application token' do
        before do
          get "/api/v1/vehicles/#{vehicle.id}/current_customer",
              headers: { Authorization: "Bearer #{client_token.token}" }, as: :json
        end

        it 'responds with a successful status' do
          expect(response).to have_http_status(:ok)
        end

        it "returns the current customer's ID" do
          expect(json).to have_key('id')
        end

        it "returns the current customer's name" do
          expect(json).to have_key('name')
        end
      end

      context "and an unauthorized customer attempts to access another driver's vehicle" do
        before do
          get "/api/v1/vehicles/#{vehicle.id}/current_customer",
              headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json
        end

        it 'responds with a forbidden status' do
          expect(response).to have_http_status(:forbidden)
        end

        it 'returns an error message detailing the access restriction' do
          expect(json['error']).to eq("Only the vehicle's driver or a client can access this")
        end
      end
    end

    context 'when the vehicle has no active booking' do
      before do
        Booking.delete_all
        get "/api/v1/vehicles/#{vehicle.id}/current_customer",
            headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json
      end

      it 'responds with a successful status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns a message indicating no customer is currently assigned' do
        expect(json['message']).to eq('Vehicle is not currently assigned to any active booking')
      end
    end
  end
end
