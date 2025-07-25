# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'associations', :aggregate_failures do
    it 'has proper associations' do
      expect(described_class.reflect_on_association(:user).macro).to eq(:has_one)
      expect(described_class.reflect_on_association(:bookings).macro).to eq(:has_many)
      expect(described_class.reflect_on_association(:payments).macro).to eq(:has_many)
      expect(described_class.reflect_on_association(:rewards).macro).to eq(:has_many)
    end
  end

  describe 'validations', :aggregate_failures do
    it 'validates presence and minimum length of location', :aggregate_failures do
      customer = described_class.new(location: '')
      expect(customer).not_to be_valid
      expect(customer.errors[:location]).to include("can't be blank")

      customer.location = 'gy'
      customer.valid?
      expect(customer.errors[:location]).to include('is too short (minimum is 3 characters)')
    end
  end

  describe 'callbacks' do
    it 'formats location before validation' do
      customer = described_class.new(location: '  chennai  ')
      customer.valid?
      expect(customer.location).to eq('Chennai')
    end
  end

  describe 'scopes', :aggregate_failures do
    let!(:customer1) { create(:customer, created_at: 2.days.ago) }
    let!(:customer2) { create(:customer, created_at: 1.day.ago) }
    let!(:booking) { create(:booking, user: create(:user, userable: customer1)) }

    it 'filters customers with bookings' do
      expect(Customer.with_bookings).to include(customer1)
      expect(Customer.with_bookings).not_to include(customer2)
    end

    it 'filters customers by recent' do
      expect(Customer.recent).to eq([customer2, customer1])
    end
  end

  describe 'instance methods' do
    let(:customer) { create(:customer) }

    it 'returns total reward points' do
      customer = create(:customer)
      user = create(:user, userable: customer)
      create(:reward, user: user, points: 5)
      create(:reward, user: user, points: 10)
      expect(customer.total_reward_points).to eq(35)
    end

    it 'returns user name if present' do
      create(:user, userable: customer, name: 'Sudharsan')
      expect(customer.name).to eq('Sudharsan')
    end

    it 'returns as undefined if the user name is nil' do
      allow(customer).to receive(:user).and_return(nil)
      expect(customer.name).to eq('undefined')
    end
  end

  describe '.ransackable_attributes' do
    it 'includes ransackable attribute names' do
      expect(described_class.ransackable_attributes).to include('location', 'created_at')
    end
  end

  describe '.ransackable_associations' do
    it 'includes ransackable associations' do
      expect(described_class.ransackable_associations).to include('bookings', 'user', 'rewards', 'payments')
    end
  end
end
