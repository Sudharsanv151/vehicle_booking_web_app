require 'rails_helper'

RSpec.describe User, type: :model do

  describe "associations" do
    it "has proper associations", :aggregate_failures do
      expect(described_class.reflect_on_association(:userable).macro).to eq(:belongs_to)
      expect(described_class.reflect_on_association(:bookings).macro).to eq(:has_many)
      expect(described_class.reflect_on_association(:ratings).macro).to eq(:has_many)
      expect(described_class.reflect_on_association(:rewards).macro).to eq(:has_many)
    end
  end

  describe "validations" do
    
    subject { build(:user) }

    it "validates presence and format of name, email, and mobile_no", :aggregate_failures do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("can't be blank")

      subject.name = "A"
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("is too short (minimum is 2 characters)")

      subject.email = "invalid_email"
      expect(subject).not_to be_valid
      expect(subject.errors[:email]).to include("is invalid")

      subject.email = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:email]).to include("is invalid")

      subject.mobile_no = "12345"
      expect(subject).not_to be_valid
      expect(subject.errors[:mobile_no]).to include("must be exactly 10 digits and only numbers")

      subject.userable = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:userable]).to include("must be assigned as a valid Customer or Driver")
    end
  end

  describe "scopes" do
    let!(:customer_user) { create(:user, userable: create(:customer)) }
    let!(:driver_user) { create(:user, userable: create(:driver)) }

    it "filters drivers" do
      expect(User.drivers).to include(driver_user)
      expect(User.drivers).not_to include(customer_user)
    end

    it "filters customers" do
      expect(User.customers).to include(customer_user)
      expect(User.customers).not_to include(driver_user)
    end

    it "filters users with rewards" do
      create(:reward, user: customer_user)
      expect(User.with_rewards).to include(customer_user)
      expect(User.with_rewards).not_to include(driver_user)
    end
  end

  describe "callbacks" do
    it "normalizes email and mobile before validation", :aggregate_failures do
      user = build(:user, email: "TEST@Email.Com", mobile_no: " 9876543210 ")
      user.valid?
      expect(user.email).to eq("test@email.com")
      expect(user.mobile_no).to eq("9876543210")
    end

    it "assigns welcome reward to customers" do
      customer = create(:customer)
      user = create(:user, userable: customer)
      expect(user.rewards.first.reward_type).to eq("Welcome Reward Bonus")
      expect(user.rewards.first.points).to eq(20)
    end

    it "does not assign welcome reward to drivers" do
      driver = create(:driver)
      user = create(:user, userable: driver)
      expect(user.rewards).to be_empty
    end
  end

  describe "instance methods" do
    it "#driver? returns true for driver" do
      user = create(:user, userable: create(:driver))
      expect(user.driver?).to be true
      expect(user.customer?).to be false
    end

    it "#customer? returns true for customer" do
      user = create(:user, userable: create(:customer))
      expect(user.customer?).to be true
      expect(user.driver?).to be false
    end

    it "#total_reward_points returns correct sum" do
      user = create(:user, userable: create(:customer))
      create(:reward, user: user, points: 10)
      create(:reward, user: user, points: 5)
      expect(user.total_reward_points).to eq(35)
    end
  end

  describe ".from_omniauth" do
    it "creates or finds user from omniauth data" do
      auth = OmniAuth::AuthHash.new({
        provider: 'github',
        uid: '12345',
        info: {
          email: 'test@github.com',
          name: 'Git User'
        }
      })

      user = User.from_omniauth(auth)
      expect(user.email).to eq("test@github.com")
      expect(user.name).to eq("Git User")
      expect(user.uid).to eq("12345")
      expect(user.provider).to eq("github")
    end
  end

  describe ".ransackable_attributes" do
    it "includes allowed ransack attributes" do
      expect(User.ransackable_attributes).to include("email", "name", "mobile_no", "userable_type", "created_at")
    end
  end

  describe ".ransackable_associations" do
    it "includes allowed ransack associations" do
      expect(User.ransackable_associations).to include("bookings", "ratings", "rewards", "userable")
    end
  end
end
