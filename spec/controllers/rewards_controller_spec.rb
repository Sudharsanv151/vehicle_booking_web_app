# require 'rails_helper'

# RSpec.describe RewardsController, type: :request do
#   render_views false

#   let(:customer) { create(:customer) }
#   let(:user) { create(:user, userable: customer) }
#   let(:driver) { create(:driver) }
#   let(:driver_user) { create(:user, userable: driver) }

#   describe 'GET #customer_history' do
#     context 'when a customer is logged in via current_user' do
#       let!(:reward1) { create(:reward, user: user, created_at: 2.days.ago) }
#       let!(:reward2) { create(:reward, user: user, created_at: 1.day.ago) }

#       before do
#         allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
#         get customer_reward_history_path
#       end

#       it 'returns a successful response' do
#         expect(response).to have_http_status(:ok)
#       end

#       it 'assigns ordered rewards to @rewards' do
#         expect(assigns(:rewards)).to eq([reward2, reward1])
#       end
#     end

#     context 'when a customer is loaded via session[:user_id]' do
#       before do
#         allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
#         get customer_reward_history_path, params: {}, session: { user_id: user.id }
#       end

#       it 'returns a successful response' do
#         expect(response).to have_http_status(:ok)
#       end
#     end

#     context 'when a driver accesses the page' do
#       before do
#         allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(driver_user)
#         get customer_reward_history_path
#       end

#       it 'redirects to root_path' do
#         expect(response).to redirect_to(root_path)
#       end

#       it 'sets alert flash message' do
#         expect(flash[:alert]).to eq("Access denied.")
#       end
#     end
#   end
# end
