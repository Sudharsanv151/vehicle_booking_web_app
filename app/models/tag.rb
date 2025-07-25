# frozen_string_literal: true

class Tag < ApplicationRecord
  has_and_belongs_to_many :vehicles

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 2 }

  scope :by_name, ->(query) { where('name ILIKE ?', "#{query}%") }
  scope :alphabetical, -> { order(:name) }

  before_validation :normalize_name

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id id_value name updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    ['vehicles']
  end

  private

  def normalize_name
    self.name = name.to_s.strip.capitalize
  end
end
