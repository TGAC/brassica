require 'rails_helper'

RSpec.describe Qtl do
  describe '#table_data' do
    let(:lm) { create(:linkage_map) }

    it 'gets proper columns' do
      qtl = create(:qtl)
      qtl.linkage_group.linkage_maps << lm
      qtl.save
      table_data = Qtl.table_data
      expect(table_data.count).to eq 1
      expect(table_data[0]).to eq [
        qtl.processed_trait_dataset.trait_descriptor.descriptor_name,
        qtl.qtl_rank,
        qtl.map_qtl_label,
        qtl.outer_interval_start,
        qtl.inner_interval_start,
        qtl.qtl_mid_position,
        qtl.inner_interval_end,
        qtl.outer_interval_end,
        qtl.peak_value,
        qtl.peak_p_value,
        qtl.regression_p,
        qtl.residual_p,
        qtl.additive_effect,
        qtl.genetic_variance_explained,
        qtl.qtl_job.id,
        lm.plant_population.id,
        lm.id,
        qtl.processed_trait_dataset.trait_descriptor.id,
        qtl.pubmed_id,
        qtl.id
      ]
    end
  end
end
