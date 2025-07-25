# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminUser, type: :model do
  describe '.ransackable_attributes' do
    it 'returns allowed attributes' do
      expect(AdminUser.ransackable_attributes).to match_array(%w[id email created_at updated_at])
    end
  end
end
