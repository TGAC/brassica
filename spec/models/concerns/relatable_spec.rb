require 'rails_helper'

RSpec.describe Relatable do
  before(:all) do
    @relatable_models = relatable_models
    @countable_models = @relatable_models.map do |model|
      model.counter_names
    end.flatten.uniq
  end

  it 'makes sure the cached counters work' do
    pp = create(:plant_population,
                linkage_maps: create_list(:linkage_map, 3, plant_population: nil))
    expect(pp.linkage_maps.count).to eq 3
    expect(pp.reload.linkage_maps_count).to eq 3
    pp.linkage_maps << create(:linkage_map, plant_population: nil)
    expect(pp.linkage_maps.count).to eq 4
    expect(pp.reload.linkage_maps_count).to eq 4
    lms = create_list(:linkage_map, 2, plant_population: nil)
    pp.linkage_maps = lms
    expect(pp.reload.linkage_maps.count).to eq 2
    expect(pp.reload.linkage_maps_count).to eq 2
  end

  it 'there exist relatable models' do
    expect(@relatable_models).not_to be_empty
  end

  it 'requires all related models to be Filterable' do
    @countable_models.each do |model|
      expect(model.classify.constantize).to include Filterable
    end
  end

  it 'requires all related models to allow correct filter param' do
    @relatable_models.each do |master_model|
      master_model.counter_names.each do |model|
        permitted_params = model.classify.constantize.send(:permitted_params)
        expect(permitted_params).not_to be_empty
        expect(permitted_params[0][:query]).
          to include "#{master_model.table_name}.id"
      end
    end
  end
end
