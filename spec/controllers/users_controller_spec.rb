# require 'rails_helper'

# RSpec.describe UsersController, type: :controller do
#   include Devise::Test::ControllerHelpers

#   let(:customer) { create(:customer) }
#   let(:driver)   { create(:driver) }
#   let(:customer_user) { create(:user, userable: customer) }
#   let(:driver_user)   { create(:user, userable: driver) }


#   describe "GET #select_role" do
#     before { sign_in customer_user }

#     it "signs out user and resets session" do
#       get :select_role
#       expect(controller.current_user).to be_nil
#     end
#   end



#   describe "GET #profile" do
#     before do
#       sign_in customer_user
#       get :profile
#     end

#     it("assigns current_user to @user") { expect(assigns(:user)).to eq(customer_user) }
#   end




#   describe "GET #new" do
#     context "when role is customer" do
#       before { get :new, params: { role: "customer" } }

#       it("assigns a new Customer to @userable") { expect(assigns(:userable)).to be_a_new(Customer) }
#     end

#     context "when role is driver" do
#       before { get :new, params: { role: "driver" } }

#       it("assigns a new Driver to @userable") { expect(assigns(:userable)).to be_a_new(Driver) }
#     end
#   end



#   describe "POST #create" do
#     context "when creating a driver" do
#       let(:driver) { Driver.create!(licence_no: "DL999999979793") } 
#       let(:valid_params) do
#         {
#           name: "Alice",
#           email: "alice@example.com",
#           password: "password123",
#           mobile_no: "9876543210",
#           role: "driver",
#           licence_no: driver.licence_no
#         }
#       end

#       it "creates user and redirects to home" do
#         post :create, params: valid_params
#         expect(response).to redirect_to(home_path)
#       end
#     end

    

#     context "when creating a customer" do
#       let(:customer) { Customer.create!(location: "Chennai") }
#       let(:valid_params) do
#         {
#           name: "Bob",
#           email: "bob@example.com",
#           password: "password123",
#           mobile_no: "9876543210",
#           role: "customer",
#           location: customer.location
#         }
#       end

#       it "creates user and redirects to home" do
#         post :create, params: valid_params
#         expect(response).to redirect_to(home_path)
#       end
#     end
#   end





#   describe "GET #home" do
#     context "when signed in" do
#       before do
#         sign_in driver_user
#         get :home
#       end

#       it("assigns current_user to @user") { expect(assigns(:user)).to eq(driver_user) }
#     end

#     context "when not signed in" do
#       before { get :home }

#       it("redirects to select_role_path") { expect(response).to redirect_to(select_role_path) }
#     end
#   end





#   describe "GET #edit" do
#     before do
#       sign_in customer_user
#       get :edit
#     end

#     it("assigns current_user to @user") { expect(assigns(:user)).to eq(customer_user) }
#   end




#   describe "PATCH #update" do
#     before { sign_in customer_user }

#     context "with valid params" do
#       before do
#         patch :update, params: {
#           user: { name: "Updated Name" },
#           location: "New City"
#         }
#       end

#       it("updates user's name") { expect(customer_user.reload.name).to eq("Updated Name") }

#       it("updates customer location") { expect(customer_user.userable.reload.location).to eq("New City") }

#       it("redirects to profile") { expect(response).to redirect_to(profile_path) }
#     end

#     context "with invalid params" do
#       before do
#         patch :update, params: {
#           user: { name: "", email: "" }
#         }
#       end

#       it("renders edit template") { expect(response).to render_template(:edit) }
#     end

#     context "when user is driver" do
#       before do
#         sign_in driver_user
#         patch :update, params: {
#           user: { name: "Driver New" },
#           licence_no: "NEWLIC123"
#         }
#       end

#       it("updates driver licence") { expect(driver_user.userable.reload.licence_no).to eq("NEWLIC123") }
#     end
#   end





#   describe "DELETE #destroy" do
#     before { sign_in customer_user }

#     it "deletes user and redirects to role selection" do
#       delete :destroy
#       expect(response).to redirect_to(select_role_path)
#     end
#   end
# end
