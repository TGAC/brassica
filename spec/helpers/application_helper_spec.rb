require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#browse_data_path' do
    it 'returns all plant populations list' do
      expect(browse_data_path).to eq data_tables_path(model: 'plant_populations')
    end
  end
end
