require 'rails_helper'

RSpec.describe DataTablesHelper do
  describe '#browse_tabs' do
    it 'sets proper tab links' do
      expect(browse_tabs).to eq({
        plant_populations: data_tables_path(model: :plant_populations),
        trait_descriptors: data_tables_path(model: :trait_descriptors)
      })
    end
  end

  describe '#datatables_source' do
    it 'passes model and query params intact' do
      allow(self).to receive(:params).and_return(model: 'model_name')
      expect(datatables_source).to eq data_tables_path(model: 'model_name')
      allow(self).to receive(:params).and_return(model: 'model_name', query: { a: 'b' })
      expect(datatables_source).to eq data_tables_path(model: 'model_name', query: { a: 'b' })
    end
  end
end
