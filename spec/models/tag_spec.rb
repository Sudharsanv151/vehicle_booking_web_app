# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'associations' do
    it 'has and belongs to many vehicles' do
      expect(described_class.reflect_on_association(:vehicles).macro).to eq(:has_and_belongs_to_many)
    end
  end

  describe 'validations' do
    subject { build(:tag) }

    it 'validates presence of name' do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("can't be blank")
    end

    it 'validates uniqueness of name (case insensitive)' do
      create(:tag, name: 'Luxury')
      duplicate = build(:tag, name: 'luxury')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include('has already been taken')
    end

    it 'validates minimum length of name' do
      subject.name = 'A'
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include('is too short (minimum is 2 characters)')
    end
  end

  describe 'scopes' do
    let!(:tag1) { create(:tag, name: 'Economy') }
    let!(:tag2) { create(:tag, name: 'Luxury') }
    let!(:tag3) { create(:tag, name: 'Electric') }

    it 'returns tags by name starting with query (case insensitive)' do
      expect(Tag.by_name('e')).to include(tag1, tag3)
      expect(Tag.by_name('e')).not_to include(tag2)
    end

    it 'returns tags in alphabetical order' do
      expect(Tag.alphabetical).to eq([tag1, tag3, tag2].sort_by(&:name))
    end
  end

  describe 'callbacks' do
    it 'capitalizes and strips whitespace from name before validation' do
      tag = build(:tag, name: '  electric ')
      tag.valid?
      expect(tag.name).to eq('Electric')
    end
  end

  describe '.ransackable_attributes' do
    it 'includes searchable attributes' do
      expect(Tag.ransackable_attributes).to include('name', 'id', 'created_at', 'updated_at')
    end
  end

  describe '.ransackable_associations' do
    it 'includes searchable associations' do
      expect(Tag.ransackable_associations).to include('vehicles')
    end
  end
end
