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

    it 'allows to go back to populations' do
      render
      expect(rendered).to include(data_tables_path(model: :plant_populations))
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
        expect(rendered).to have_tag('th.annotations')
      end
    end
  end

  it 'has all table and count column names translated' do
    annotable_tables.each do |table|
      allow(view).to receive(:params).and_return(model: table)
      model_klass = table.singularize.camelize.constantize
      columns = []
      columns += model_klass.table_columns if model_klass.respond_to? :table_columns
      columns += model_klass.count_columns if model_klass.respond_to? :count_columns
      columns.each do |column|
        _table, _column = view.extract_column(column)
        expect(I18n.t("tables.#{_table}.#{_column}")).
          not_to include 'translation missing'
      end
    end
  end
end
