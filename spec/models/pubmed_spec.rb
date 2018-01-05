require 'rails_helper'

RSpec.describe ActiveRecord::Base do
  it 'ensures pubmed_id is the next to last field' do
    [LinkageMap, PlantTrial, Qtl].each do |model|
      expect(model.send(:ref_columns)[-2]).to eq 'pubmed_id'
      instance = create(model.name.underscore.to_sym)
      table_data = model.table_data
      expect(table_data.count).to eq 1
      expect(table_data[0][-2]).to eq instance.pubmed_id
    end
  end
end
