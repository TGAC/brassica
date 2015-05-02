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
      expect(rendered).to include t('tables.trait_descriptors.trait_scores')
    end
  end

  context 'for "publishable" models' do
    it 'contains additional pubmed column' do
      %w(plant_trials qtls linkage_maps).each do |model|
        allow(view).to receive(:params).and_return(model: model)
        render
        expect(rendered).to include 'pubmed'
      end
    end

    it 'does not show pubmed column in group mode' do
      allow(view).to receive(:params).and_return(model: 'qtls', group: true)
      render
      expect(rendered).not_to include 'pubmed'
    end
  end

  context 'when run for annotable models' do
    it 'shows annotations column' do
      (displayable_tables & annotable_tables).each do |table|
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
          to include(browse_tabs[view.active_tab_label].gsub('&','&amp;'))
      end
    end
  end

  it 'has all table and count column names translated' do
    displayable_tables.each do |table|
      allow(view).to receive(:params).and_return(model: table)
      model_klass = table.singularize.camelize.constantize
      model_klass.table_columns.each do |column|
        _table, _column = view.extract_column(column)
        expect(I18n.t("tables.#{_table}.#{_column}")).
          not_to include 'translation missing'
      end
    end
  end

  context 'when server-side filtering is on' do
    it 'adds show all button when querying for certain records' do
      allow(view).to receive(:params).and_return(model: 'plant_lines', query: { x: 'a'})
      render
      expect(rendered).to include('table-see-all-button')
    end

    it 'adds show all button when fetching ES-found records' do
      allow(view).to receive(:params).and_return(model: 'plant_lines', fetch: 'b')
      render
      expect(rendered).to include('table-see-all-button')
    end

    it 'does not add show all button when not querying nor fetching' do
      allow(view).to receive(:params).and_return(model: 'plant_lines')
      render
      expect(rendered).not_to include('table-see-all-button')
    end
  end
end
