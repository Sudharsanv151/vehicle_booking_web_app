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

    let!(:booking1) { create(:booking) }
    let!(:booking2) { create(:booking) }
    let!(:driver_booking) { create(:booking, vehicle: vehicle) }
    let(:orphan_user) { create(:user, userable: nil) }
    let(:orphan_token) { create(:access_token, resource_owner_id: orphan_user.id) }

    context "when no token or invalid user" do
      it "returns 401 when no token is provided" do
        get "/api/v1/bookings", as: :json
        expect(response).to have_http_status(:unauthorized)
      end
      
    end

    context "when accessed using client credentials token" do
      it "returns 200 status" do
        get "/api/v1/bookings", headers: { Authorization: "Bearer #{client_token.token}" }, as: :json
        expect(response).to have_http_status(:ok)
      end

      it "returns all bookings" do
        get "/api/v1/bookings", headers: { Authorization: "Bearer #{client_token.token}" }, as: :json
        expect(json.size).to eq(Booking.count)
      end
    end

    context "when accessed by a customer" do
      let!(:customer_booking) { create(:booking, user: customer_user) }

      it "returns 200 status" do
        get "/api/v1/bookings", headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json
        expect(response).to have_http_status(:ok)
      end

      it "includes customer's own booking" do
        get "/api/v1/bookings", headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json
        expect(json.map { |b| b["booking"]["id"] }).to include(customer_booking.id)
      end

      it "excludes other users' bookings" do
        get "/api/v1/bookings", headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json
        expect(json.map { |b| b["booking"]["id"] }).not_to include(booking1.id)
      end
    end

    context "when accessed by a driver" do
      it "returns 200 status" do
        get "/api/v1/bookings", headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json
        expect(response).to have_http_status(:ok)
      end

      it "includes bookings for driver's vehicle" do
        get "/api/v1/bookings", headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json
        expect(json.map { |b| b["booking"]["id"] }).to include(driver_booking.id)
      end

      it "excludes unrelated bookings" do
        get "/api/v1/bookings", headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json
        expect(json.map { |b| b["booking"]["id"] }).not_to include(booking1.id)
      end
    end
  end






  describe "GET /api/v1/bookings/:id" do
    context "when a customer views their booking" do
      subject { get "/api/v1/bookings/#{booking.id}", headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json }

      before { subject }

      it "responds with a successful status" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "when a driver views a booking for their vehicle" do
      subject { get "/api/v1/bookings/#{booking.id}", headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json }

      before { subject }

      it "responds with a successful status" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "when a customer tries to view someone else's booking" do
      let(:another_customer) { create(:customer) }
      let(:another_user)     { create(:user, userable: another_customer) }
      let(:another_token)    { create(:access_token, resource_owner_id: another_user.id) }

      subject { get "/api/v1/bookings/#{booking.id}", headers: { Authorization: "Bearer #{another_token.token}" }, as: :json }

      it "responds with forbidden status" do
        subject
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when a driver tries to view a booking not linked to their vehicle" do
      let(:other_driver)  { create(:driver) }
      let(:other_user)    { create(:user, userable: other_driver) }
      let(:other_token)   { create(:access_token, resource_owner_id: other_user.id) }

      subject { get "/api/v1/bookings/#{booking.id}", headers: { Authorization: "Bearer #{other_token.token}" }, as: :json }

      it "responds with forbidden status" do
        subject
        expect(response).to have_http_status(:forbidden)
      end
    end
  end






  describe "POST /api/v1/bookings" do
    let(:new_vehicle) { create(:vehicle) }
    let(:valid_params) do
      {
        booking: {
          vehicle_id: new_vehicle.id,
          start_location: "Erode",
          end_location: "Tirupur",
          price: 1000,
          booking_date: Time.current + 2.days,
          start_time: Time.current + 3.days
        }
      }
    end

    context "when a customer creates a booking" do
      subject do
        post "/api/v1/bookings",
            params: valid_params,
            headers: { Authorization: "Bearer #{customer_token.token}" },
            as: :json
      end

      it "creates a new booking and responds with created status" do
        expect { subject }.to change(Booking, :count).by(1)
        expect(response).to have_http_status(:created)
      end

      it "returns the created booking with correct vehicle ID" do
        subject
        expect(json["booking"]["vehicle_id"]).to eq(new_vehicle.id)
      end

      it "returns the created booking with the correct start location" do
        subject
        expect(json["booking"]["start_location"]).to eq("Erode")
      end
    end

    context "when a driver attempts to create a booking" do
      subject do
        post "/api/v1/bookings",
            params: valid_params,
            headers: { Authorization: "Bearer #{driver_token.token}" },
            as: :json
      end

      before { subject }

      it "responds with a forbidden status" do
        expect(response).to have_http_status(:forbidden)
      end

      it "returns an authorization error message" do
        expect(json["error"]).to eq("You are not authorized to perform this action")
      end
    end

    context "when a client application attempts to create a booking" do
      subject do
        post "/api/v1/bookings",
            params: valid_params,
            headers: { Authorization: "Bearer #{client_token.token}" },
            as: :json
      end

      before { subject }

      it "responds with a forbidden status" do
        expect(response).to have_http_status(:forbidden)
      end

      it "returns an error message about client credentials access" do
        expect(json["error"]).to eq("Client credentials token cannot access this resource")
      end
    end

    context "when required fields are missing during booking creation" do
      subject do
        post "/api/v1/bookings",
            params: { booking: { vehicle_id: nil, start_location: "Some Loc" } },
            headers: { Authorization: "Bearer #{customer_token.token}" },
            as: :json
      end

      before { subject }

      it "responds with an unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not return a validation error for 'vehicle_id' directly as it might be nested" do
        expect(json).not_to have_key("vehicle_id")
      end

      it "returns errors in the response body" do
        expect(json["errors"]).not_to be_empty
      end
    end
  end




  describe "PUT /api/v1/bookings/:id" do
    let(:update_params) do
      {
        booking: {
          status: true,
          ride_status: true,
          start_time: Time.current + 1.hour,
          end_time: Time.current + 2.hours
        }
      }
    end

    context "when a driver updates a booking" do
      subject do
        put "/api/v1/bookings/#{booking.id}",
            params: update_params,
            headers: { Authorization: "Bearer #{driver_token.token}" },
            as: :json
      end

      before { subject }

      it "responds with a successful status" do
        expect(response).to have_http_status(:ok)
      end

      it "updates the booking status to true" do
        expect(json["booking"]["status"]).to eq(true)
      end
    end

    context "when update fails due to invalid data" do
      let(:invalid_update_params) do
        {
          booking: {
            status: true,
            ride_status: true,
            start_time: nil,
            end_time: Time.current + 1.hour
          }
        }
      end

      subject do
        put "/api/v1/bookings/#{booking.id}",
            params: invalid_update_params,
            headers: { Authorization: "Bearer #{driver_token.token}" },
            as: :json
      end

      before { subject }

      it "responds with an unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns errors in the response body" do
        expect(json["errors"]).not_to be_empty
      end
    end

    context "when a customer attempts to update a booking" do
      subject do
        put "/api/v1/bookings/#{booking.id}",
            params: update_params,
            headers: { Authorization: "Bearer #{customer_token.token}" },
            as: :json
      end

      before { subject }

      it "responds with a forbidden status" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end




  describe "GET /api/v1/bookings/ongoing" do
    context "when a customer requests ongoing bookings" do
      let!(:ongoing_booking_customer) { create(:booking, user: customer_user, vehicle: vehicle, status: true, ride_status: false) }

      subject { get "/api/v1/bookings/ongoing", headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json }

      before { subject }

      it "responds with a successful status" do
        expect(response).to have_http_status(:ok)
      end

      it "returns ongoing bookings for the customer" do
        expect(json.first["booking"]["id"]).to eq(ongoing_booking_customer.id)
      end
    end

    context "when a driver requests ongoing bookings" do
      let!(:ongoing_booking_driver) { create(:booking, vehicle: vehicle, status: true, ride_status: false) }

      subject do
        get "/api/v1/bookings/ongoing",
          headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json
      end

      before { subject }

      it "responds with a successful status" do
        expect(response).to have_http_status(:ok)
      end

      it "returns a list of ongoing bookings" do
        expect(json).to be_an(Array)
      end

      it "returns the correct number of ongoing bookings for the driver's vehicle" do
        expect(json.size).to eq(1)
      end

      it "includes the specific ongoing booking for the driver's vehicle" do
        expect(json.first["booking"]["id"]).to eq(ongoing_booking_driver.id)
      end
    end
  end



  describe "GET /api/v1/bookings/pending" do
    context "when a driver requests pending bookings" do
      let!(:pending_booking_driver) { create(:booking, user: customer_user, vehicle: vehicle, status: false) }

      subject { get "/api/v1/bookings/pending", headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json }

      before { subject }

      it "responds with a successful status" do
        expect(response).to have_http_status(:ok)
      end

      it "returns pending bookings for the driver's vehicle" do
        expect(json.first["booking"]["id"]).to eq(pending_booking_driver.id)
      end
    end

    context "when customer requests pending bookings" do
      let!(:pending_booking_customer) { create(:booking, user: customer_user, vehicle: vehicle, status: false) }

      subject { get "/api/v1/bookings/pending", headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json }

      before { subject }      
      
      it "responds with a successful status" do
        expect(response).to have_http_status(:ok)
      end

      it "returns pending booking requests of customers" do
        expect(json.first["booking"]["id"]).to eq(pending_booking_customer.id)
      end

    end
  end

  describe "GET /api/v1/bookings/:id/customer_info" do
    context "when a driver requests customer information for a booking" do
      subject { get "/api/v1/bookings/#{booking.id}/customer_info", headers: { Authorization: "Bearer #{driver_token.token}" }, as: :json }

      before { subject }

      it "responds with a successful status" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the customer's ID" do
        expect(json).to have_key("id")
      end

      it "returns the customer's email" do
        expect(json).to have_key("email")
      end

      it "returns the customer's mobile number" do
        expect(json).to have_key("mobile_no")
      end
    end

    context "when a customer attempts to request customer information for a booking" do
      subject { get "/api/v1/bookings/#{booking.id}/customer_info", headers: { Authorization: "Bearer #{customer_token.token}" }, as: :json }

      before { subject }

      it "responds with a forbidden status" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end