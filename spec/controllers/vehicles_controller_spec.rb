# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VehiclesController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:driver) { create(:driver) }
  let(:user)   { create(:user, userable: driver) }
  let(:vehicle) { create(:vehicle, driver: driver) }
  let(:tag) { create(:tag) }

  before { sign_in user }

  describe 'GET #index' do
    context 'without filters' do
      before { get :index }

      it 'responds successfully' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with search query' do
      let!(:matching_vehicle) { create(:vehicle, model: 'Tesla', driver: driver) }

      before do
        allow(Kaminari).to receive(:paginate_array).and_call_original
        get :index, params: { query: 'tesla' }
      end

      it 'includes the searched vehicle' do
        expect(assigns(:vehicles)).to include(matching_vehicle)
      end
    end

    context 'with filters' do
      let!(:filtered_vehicle) { create(:vehicle, driver: driver, vehicle_type: 'Bike') }

      before { get :index, params: { vehicle_type: 'Bike' } }

      it 'filters by vehicle type' do
        expect(assigns(:vehicles)).to include(filtered_vehicle)
      end
    end
  end

  describe 'GET #new' do
    before { get :new }

    it 'assigns a new vehicle' do
      expect(assigns(:vehicle)).to be_a_new(Vehicle)
    end
  end

  describe 'POST #create' do
    let(:vehicle_params) do
      attributes_for(:vehicle).merge(tag_ids: [tag.id])
    end

    context 'with valid params' do
      let(:persisted_vehicle) { build(:vehicle, driver: driver) }

      before do
        allow(persisted_vehicle).to receive(:persisted?).and_return(true)
        allow_any_instance_of(VehicleCreationService).to receive(:call).and_return(persisted_vehicle)
        post :create, params: { vehicle: attributes_for(:vehicle), new_tags: nil }
      end

      it 'redirects to driver vehicles' do
        expect(response).to redirect_to(driver_vehicles_path)
      end
    end

    context 'with invalid params' do
      before do
        allow_any_instance_of(VehicleCreationService).to receive(:call).and_return(Vehicle.new)
        post :create, params: { vehicle: { model: '' }, new_tags: nil }
      end

      it 'renders new template' do
        expect(response).to render_template(:new)
      end
    end

    context 'when vehicle is persisted successfully' do
      before do
        persisted_vehicle = build(:vehicle, driver: driver)
        allow(persisted_vehicle).to receive(:persisted?).and_return(true)
        allow_any_instance_of(VehicleCreationService).to receive(:call).and_return(persisted_vehicle)

        post :create, params: { vehicle: attributes_for(:vehicle), new_tags: nil }
      end

      it 'redirects with success flash' do
        expect(flash[:notice]).to eq('Vehicle added successfully!')
      end
    end
  end

  describe 'GET #edit' do
    before { get :edit, params: { id: vehicle.id } }

    it 'assigns vehicle to edit' do
      expect(assigns(:vehicle)).to eq(vehicle)
    end
  end

  describe 'PATCH #update' do
    context 'with valid params' do
      before do
        patch :update, params: { id: vehicle.id, vehicle: { model: 'Updated' } }
      end

      it 'redirects after update' do
        expect(response).to redirect_to(driver_vehicles_path)
      end
    end

    context 'with invalid params' do
      before do
        patch :update, params: { id: vehicle.id, vehicle: { model: nil } }
      end

      it 'renders edit on failure' do
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when vehicle has unfinished bookings' do
      before do
        create(:booking, vehicle: vehicle, ride_status: false)
        delete :destroy, params: { id: vehicle.id }
      end

      it 'does not delete vehicle' do
        expect(flash[:alert]).to eq('Cannot delete vehicle with active or pending bookings')
      end
    end

    context 'when vehicle has only finished bookings' do
      before do
        create(:booking, vehicle: vehicle, ride_status: true)
        delete :destroy, params: { id: vehicle.id }
      end

      it 'deletes vehicle' do
        expect(response).to redirect_to(driver_vehicles_path)
      end
    end
  end

  describe 'GET #driver_index' do
    context 'without filters' do
      let!(:v1) { create(:vehicle, driver: driver) }
      let!(:v2) { create(:vehicle, driver: driver) }

      before { get :driver_index }

      it "loads driver's vehicles" do
        expect(assigns(:vehicles)).to all(have_attributes(driver_id: driver.id))
      end
    end

    context 'when searching by query' do
      let!(:matching_vehicle) { create(:vehicle, model: 'TestBike', driver: driver) }
      let!(:non_matching_vehicle) { create(:vehicle, model: 'OtherCar', driver: driver) }

      before { get :driver_index, params: { query: 'Test' } }

      it 'includes vehicle matching query' do
        expect(assigns(:vehicles)).to include(matching_vehicle)
      end
    end

    context 'when filtering by vehicle_type' do
      let!(:bike) { create(:vehicle, vehicle_type: 'Bike', driver: driver) }
      let!(:car) { create(:vehicle, vehicle_type: 'Car', driver: driver) }

      before { get :driver_index, params: { vehicle_type: 'Bike' } }

      it 'includes vehicles with specified type' do
        expect(assigns(:vehicles)).to include(bike)
      end
    end

    context 'when filtering by tag_id' do
      let!(:tagged_vehicle) { create(:vehicle, driver: driver, tags: [tag]) }
      let!(:untagged_vehicle) { create(:vehicle, driver: driver) }

      before { get :driver_index, params: { tag_id: tag.id } }

      it 'includes vehicles with specified tag' do
        expect(assigns(:vehicles)).to include(tagged_vehicle)
      end
    end

    context 'when filtering by min_rating' do
      let!(:high_rated_vehicle) { create(:vehicle, driver: driver) }
      let!(:low_rated_vehicle)  { create(:vehicle, driver: driver) }

      before do
        create(:rating, rateable: high_rated_vehicle, stars: 5)
        create(:rating, rateable: low_rated_vehicle, stars: 2)

        allow(high_rated_vehicle).to receive(:average_rating).and_return(5.0)
        allow(low_rated_vehicle).to receive(:average_rating).and_return(2.0)

        allow(Vehicle).to receive(:where).and_call_original

        allow(Kaminari).to receive(:paginate_array).and_call_original

        get :driver_index, params: { min_rating: 4 }
      end

      it('includes high-rated vehicle') do
        expect(assigns(:vehicles)).to include(high_rated_vehicle)
      end

      it('excludes low-rated vehicle') do
        expect(assigns(:vehicles)).not_to include(low_rated_vehicle)
      end
    end
  end

  describe 'GET #ratings' do
    before { get :ratings, params: { vehicle_id: vehicle.id } }

    it("assigns vehicle's ratings") do
      expect(assigns(:ratings)).to eq(vehicle.ratings)
    end
  end

  describe 'GET #ride_history' do
    let!(:completed_booking) { create(:booking, vehicle: vehicle, ride_status: true) }

    before { get :ride_history, params: { vehicle_id: vehicle.id } }

    it('assigns completed ride history') do
      expect(assigns(:bookings)).to include(completed_booking)
    end
  end
end
