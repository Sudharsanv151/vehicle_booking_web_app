require 'rails_helper'

RSpec.describe BookingsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }
  let(:driver) { create(:driver) }
  let(:vehicle) { create(:vehicle, driver: driver) }
  let(:booking) { create(:booking, user: user, vehicle: vehicle) }

  before { sign_in user }

  describe "GET #index" do
    let!(:requested_booking) { create(:booking, user: user, status: false) }
    let!(:ongoing_booking) { create(:booking, user: user, status: true, ride_status: false) }

    before { get :index }

    it "assigns requested and ongoing bookings" do
      expect(assigns(:requested)).to be_present
      expect(assigns(:ongoing)).to be_present
    end
  end



  describe "GET #new" do
    before { get :new }

    it "assigns a new booking" do
      expect(assigns(:booking)).to be_a_new(Booking)
    end

    it "renders the new template" do
      expect(response).to render_template(:new)
    end
  end





  describe "POST #create" do
    context "with valid params" do
      let(:booking_params) { attributes_for(:booking, vehicle_id: vehicle.id) }

      it "creates a new booking" do
        post :create, params: { booking: booking_params }
        expect(response).to redirect_to(bookings_path)
      end
    end

    context "with invalid params" do
      let(:invalid_params) { attributes_for(:booking, vehicle_id: vehicle.id, start_location: nil) }

      it "renders new template" do
        post :create, params: { booking: invalid_params }
        expect(response).to render_template(:new)
      end
    end
  end





  describe "DELETE #destroy" do
    context "when user owns the booking and not confirmed" do
      let!(:booking) { create(:booking, user: user, status: false) }

      it "destroys the booking" do
        delete :destroy, params: { id: booking.id }
        expect(flash[:notice]).to eq("Booking cancelled!")
      end
    end

    context "when user cannot cancel" do
      let!(:booking) { create(:booking, user: user, status: true) }

      it "does not destroy the booking" do
        delete :destroy, params: { id: booking.id }
        expect(flash[:alert]).to eq("Cannot cancel booking")
      end
    end
  end





  describe "PATCH #propose_price" do
    before { allow(BookingNegotiationService).to receive(:propose_price).and_return(true) }

    context "when customer already accepted" do
      before { allow_any_instance_of(Booking).to receive(:customer_accepted).and_return(true) }

      it "sets alert flash" do
        patch :propose_price, params: { id: booking.id, proposed_price: 100 }
        expect(flash[:alert]).to eq("Customer has already accepted the final price")
      end
    end

    context "when proposal succeeds" do
      before { allow_any_instance_of(Booking).to receive(:customer_accepted).and_return(false) }

      it "sets notice flash" do
        patch :propose_price, params: { id: booking.id, proposed_price: 100 }
        expect(flash[:notice]).to eq("Proposed new price to customer")
      end
    end

    before { allow_any_instance_of(Booking).to receive(:customer_accepted).and_return(false) }

    context "when proposal fails" do
      before { allow(BookingNegotiationService).to receive(:propose_price).and_return(false) }

      it "sets alert flash" do
        patch :propose_price, params: { id: booking.id, proposed_price: 100 }
        expect(flash[:alert]).to eq("Failed to propose price")
      end
    end

  end





  describe "PATCH #accept_price" do

    context "when accept_price suceeds" do
      before { allow(BookingNegotiationService).to receive(:accept_price).and_return(true) }

      it "sets notice flash" do
        patch :accept_price, params: { id: booking.id }
        expect(flash[:notice]).to eq("New price accepted!")
      end
    end

    context "when accept_price fails" do
      before { allow(BookingNegotiationService).to receive(:accept_price).and_return(false) }

      it "sets alert flash" do
        patch :accept_price, params: { id: booking.id }
        expect(flash[:alert]).to eq("Failed to accept new price")
      end
    end

  end





  describe "PATCH #accept" do
    before { allow(BookingStatusService).to receive(:accept) }

    it "redirects to driver ongoing" do
      patch :accept, params: { id: booking.id }
      expect(response).to redirect_to(driver_ongoing_path)
    end
  end





  describe "PATCH #reject" do
    before { allow(BookingStatusService).to receive(:reject) }

    it "redirects to booking requests" do
      patch :reject, params: { id: booking.id }
      expect(response).to redirect_to(booking_requests_path)
    end
  end




  describe "PATCH #finish" do
    before { allow(BookingStatusService).to receive(:finish) }

    it "redirects to driver ride history" do
      patch :finish, params: { id: booking.id }
      expect(response).to redirect_to(driver_ride_history_path)
    end
  end




  describe "GET #customer_history" do
    let!(:completed_booking) { create(:booking, user: user, status: true, ride_status: true) }

    it "assigns completed bookings" do
      get :customer_history
      expect(assigns(:completed)).to be_present
    end
  end




  describe "driver actions" do

    let(:driver) { create(:driver) }
    let(:user) { create(:user, userable: driver) }
    let(:vehicle) { create(:vehicle, driver: driver) }

    before do
      # This sets current_user, which populates @driver_id via before_action
      allow(controller).to receive(:current_user).and_return(user)
    end

    describe "GET #driver_history" do
      let!(:booking) { create(:booking, vehicle: vehicle, status: true, ride_status: true) }

      it "assigns bookings" do
        get :driver_history
        expect(assigns(:bookings)).to be_present
      end
    end

    describe "GET #driver_ongoing" do
      let!(:booking) { create(:booking, vehicle: vehicle, status: true, ride_status: false) }

      it "assigns ongoing bookings" do
        get :driver_ongoing
        expect(assigns(:ongoing_bookings)).to be_present
      end
    end

    describe "GET #requests" do
      let!(:booking) { create(:booking, vehicle: vehicle, status: false, customer_accepted: nil) }

      it "assigns requests" do
        get :requests
        expect(assigns(:requests)).to be_present
      end
    end
  end


  
  describe "when booking not found" do

    it "redirects with flash alert" do
      delete :destroy, params: { id: 0 }  # non-existent ID
      expect(flash[:alert]).to eq("Booking not found")
    end
  end



end
