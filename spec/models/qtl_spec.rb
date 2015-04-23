require 'rails_helper'

RSpec.describe Qtl do
  describe '#table_data' do
    let(:lm) { create(:linkage_map) }

    it 'properly calculates grouped qtls number' do
      lg = create(:linkage_group, linkage_maps: [lm])
      ptd = create(:processed_trait_dataset)
      create_list(:qtl, 3, linkage_group: lg, processed_trait_dataset: ptd)
      table_data = Qtl.table_data
      expect(table_data.count).to eq 1
      expect(table_data[0].last).to eq 3
    end

    it 'properly calculates associated trait scores' do
      lg = create(:linkage_group, linkage_maps: [lm])
      td1 = create(:trait_descriptor, descriptor_name: 'dn', trait_scores_count: 3)
      td2 = create(:trait_descriptor, descriptor_name: 'dn', trait_scores_count: 7)
      ptd1 = create(:processed_trait_dataset, trait_descriptor: td1)
      ptd2 = create(:processed_trait_dataset, trait_descriptor: td2)
      create(:qtl, linkage_group: lg, processed_trait_dataset: ptd1)
      create(:qtl, linkage_group: lg, processed_trait_dataset: ptd2)
      table_data = Qtl.table_data
      expect(table_data.count).to eq 1
      expect(table_data[0][-2]).to eq 10
    end

    it 'gets proper columns' do
      qtl = create(:qtl)
      qtl.linkage_group.linkage_maps << lm
      qtl.save
      table_data = Qtl.table_data
      expect(table_data.count).to eq 1
      expect(table_data[0]).to eq [
        lm.plant_population.taxonomy_term.name,
        lm.plant_population.name,
        lm.linkage_map_label,
        qtl.processed_trait_dataset.trait_descriptor.descriptor_name,
        0,
        1
      ]
    end
  end
end
