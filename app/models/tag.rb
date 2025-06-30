class Tag < ApplicationRecord
  has_and_belongs_to_many :vehicles

  validates :name, presence:true, uniqueness:{case_sensitive:false}, length:{minimum:2}

  scope :by_name, ->(query){where("name ILIKE ?", "#{query}%")}
  scope :alphabetical, ->{order(:name)}

  before_validation :normalize_name

  def usage_count
    vehicles.count
  end

  private

  def normalize_name
    self.name = name.to_s.strip.capitalize
  end


end
