require 'rails_helper'

RSpec.describe ActiveRecord::Base do
  it 'ensures pubmed_id is the next to last field' do
    [LinkageMap, PlantTrial, Qtl].each do |model|
      expect(model.send(:ref_columns)[-2]).to eq 'pubmed_id'
    end
  end
end
