require 'rails_helper'

RSpec.describe 'data_tables/index.html.haml' do
  context 'when run for plant lines' do
    before(:each) do
      allow(view).to receive(:params).and_return(model: 'plant_lines')
    end

    it 'contains proper columns' do
      render
      PlantLine.table_columns.each do |column|
        column = "plant_lines.#{column}" unless column.include? '.'
        expect(rendered).to include t("tables.#{column}")
      end
    end
  end

  context 'when run for qtls' do
    before(:each) do
      allow(view).to receive(:params).and_return(model: 'qtls')
    end

    it 'contains additional count columns' do
      render
      expect(rendered).to include t('tables.qtl.id')
      expect(rendered).to include t('tables.trait_descriptors.trait_scores_count')
    end
  end

  context 'when run for annotable models' do
    it 'shows annotations column' do
      annotable_tables.each do |table|
        allow(view).to receive(:params).and_return(model: table)
        render
        expect(rendered).to include(table)
        expect(rendered).to have_tag('th.annotations')
      end
    end
  end

  context 'when run for drill-down tables' do
    it 'shows proper back button to main tables' do
      (displayable_tables - browse_tabs.keys.map(&:to_s)).each do |table|
        allow(view).to receive(:params).and_return(model: table)
        render
        expect(rendered).to include(table)
        expect(rendered).
          to include(browse_tabs[view.active_tab_label])
      end
    end
  end

  it 'has all column names translated' do
    pending 'test when annotable concern is merged'
    fail
  end
end
