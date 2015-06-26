require 'rails_helper'

RSpec.describe Api::Model do
  describe '#has_many_associations' do
    it "returns association data" do
      pv_assocs = Api::Model.new("plant_variety").has_many_associations
      pp_assocs = Api::Model.new("plant_population").has_many_associations

      expect(pv_assocs.map(&:name)).to match_array %w(plant_lines)
      expect(pv_assocs.first.to_h).to include(
        name: 'plant_lines',
        primary_key: 'id',
        param: 'plant_line_ids',
        klass: PlantLine
      )

      expect(pp_assocs.map(&:name)).to match_array %w(linkage_maps population_loci
        plant_trials plant_population_lists plant_lines)
    end
  end

  describe '#has_and_belongs_to_many_associations' do
    it "returns association data" do
      pv_assocs = Api::Model.new("plant_variety").has_and_belongs_to_many_associations
      pp_assocs = Api::Model.new("plant_population").has_and_belongs_to_many_associations

      expect(pv_assocs.map(&:name)).to match_array %w(countries_registered
        countries_of_origin)

      expect(pp_assocs).to be_empty
    end
  end
end
