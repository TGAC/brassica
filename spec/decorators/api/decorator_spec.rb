require "rails_helper"

RSpec.describe Api::Decorator do

  subject { described_class.new(object) }

  let(:json) { subject.as_json }

  describe "#as_json" do
    context "decorating PlantLine" do
      let!(:object) { create :plant_line, :with_has_many_associations }

      it "includes has_many associations" do
        expect(json['fathered_descendants_ids']).to eq object.fathered_descendants.pluck(:id)
        expect(json['mothered_descendants_ids']).to eq object.mothered_descendants.pluck(:id)
        expect(json['plant_accessions_ids']).to eq object.plant_accessions.pluck(:id)
        expect(json['plant_populations_ids']).to eq object.plant_populations.pluck(:id)
      end
    end

    context "decorating PlantVariety" do
      let!(:object) { create :plant_variety, :with_has_many_associations }

      it "includes has_many associations" do
        expect(json['plant_lines_ids']).to eq object.plant_lines.pluck(:id)
      end

      it "expands has_many associations" do
        expect(json['countries_of_origin_ids']).to eq nil
        expect(json['countries_registered_ids']).to eq nil
        expect(json['countries_of_origin'].map{ |c| c['country_code'] }).
          to eq object.countries_of_origin.pluck(:country_code)
        expect(json['countries_registered'].map{ |c| c['country_code'] }).
          to eq object.countries_registered.pluck(:country_code)
      end
    end

    context "decorating PlantPopulation" do
      let!(:object) { create :plant_population, :with_has_many_associations }

      it "includes has_many associations" do
        expect(json['plant_lines_ids']).to eq object.plant_lines.pluck(:id)
        expect(json['plant_trials_ids']).to eq object.plant_trials.pluck(:id)
        expect(json['population_loci_ids']).to eq object.population_loci.pluck(:id)
        expect(json['linkage_maps_ids']).to eq object.linkage_maps.pluck(:id)
      end
    end
  end
end
