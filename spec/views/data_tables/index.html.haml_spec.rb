require 'rails_helper'

RSpec.describe 'data_tables/index.html.haml' do
  context 'when run for plant lines' do
    before(:each) do
      allow(view).to receive(:controller_name).and_return('plant_lines')
      allow(view).to receive(:action_name).and_return('index')
      allow(view).to receive(:params).and_return(model: 'plant_lines')
    end

    it 'contains proper columns' do
      render
      PlantLine.table_columns.each do |column|
        column = "plant_lines.#{column}" unless column.include? '.'
        expect(rendered).to include t("tables.#{column}")
      end
    end

    it 'allows to go back to populations' do
      render
      expect(rendered).to include(data_tables_path(model: :plant_populations))
    end
  end
end
