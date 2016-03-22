require 'rails_helper'

RSpec.describe DataTablesHelper do
  describe '#browse_tabs' do
    it 'sets proper tab links' do
      expect(browse_tabs).to eq({
        plant_populations: data_tables_path(model: :plant_populations),
        trait_descriptors: data_tables_path(model: :trait_descriptors, group: true),
        plant_trials: data_tables_path(model: :plant_trials),
        linkage_maps: data_tables_path(model: :linkage_maps),
        qtl: data_tables_path(model: :qtl),
        marker_assays: data_tables_path(model: :marker_assays)
      })
    end
  end

  describe '#active_tab_label' do
    it 'returns meaningful label for every tableized model' do
      displayable_tables.each do |table|
        allow(self).to receive(:params).and_return(model: table)
        expect(active_tab_label).not_to eq :wrong_tab
      end
    end
  end

  describe '#datatables_source' do
    it 'passes model, fetch and query params intact' do
      allow(self).to receive(:params).and_return(model: 'model_name')
      expect(datatables_source).to eq data_tables_path(model: 'model_name', format: 'json')
      allow(self).to receive(:params).and_return(model: 'model_name', query: { a: 'b' })
      expect(datatables_source).to eq data_tables_path(model: 'model_name', query: { a: 'b' }, format: 'json')
      allow(self).to receive(:params).and_return(model: 'model_name', fetch: 'n')
      expect(datatables_source).to eq data_tables_path(model: 'model_name', fetch: 'n', format: 'json')
    end
  end

  describe '#extract_column' do
    before :each do
      allow(self).to receive(:params).and_return(model: 'model_name')
    end

    it 'adds model name to column name' do
      expect(extract_column('column_name')).to eq %w(model_name column_name)
    end

    it 'does not add model name when present in argument' do
      expect(extract_column('right_model_name.column_name')).
        to eq %w(right_model_name column_name)
    end

    it 'honor aliasing case insensitive' do
      expect(extract_column('mn.cn AS column_name')).
        to eq %w(model_name column_name)
      expect(extract_column('mn.cn as column_name')).
        to eq %w(model_name column_name)
      expect(extract_column('mn.cn as right_model_name.column_name')).
        to eq %w(right_model_name column_name)
    end

    it 'strips the aggregate function' do
      expect(extract_column('count(column_name)')).
        to eq %w(model_name column_name)
      expect(extract_column('count(right_model_name.column_name)')).
        to eq %w(right_model_name column_name)
    end

    it 'gets rid of _count suffix' do
      expect(extract_column('relation_name_count')).
        to eq %w(model_name relation_name)
    end
  end
end
