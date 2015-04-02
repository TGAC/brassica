require 'rails_helper'

RSpec.describe DataTablesHelper do
  describe '#browse_tabs' do
    it 'sets proper tab links' do
      expect(browse_tabs).
        to match_array(
          [[:plant_populations, data_tables_path(model: :plant_populations)],
          [:trait_descriptors, data_tables_path(model: :trait_descriptors)]]
        )
    end
  end

  describe '#datatables_source' do
    before(:each) do
      allow(self).to receive(:controller_name).and_return('plant_lines')
      allow(self).to receive(:action_name).and_return('index')
    end

    it 'does not crash when not all params are available' do
      expect(datatables_source).to eq plant_lines_path
    end

    it 'passes model and query params intact' do
      allow(self).to receive(:params).and_return(model: 'model_name')
      expect(datatables_source).to eq plant_lines_path(model: 'model_name')
      allow(self).to receive(:params).and_return(query: { a: 'b' })
      expect(datatables_source).to eq plant_lines_path(query: { a: 'b' })
    end
  end
end
