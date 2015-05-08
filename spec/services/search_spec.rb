require 'rails_helper'

RSpec.describe Search, :elasticsearch, :dont_clean_db do

  before(:all) do
    WebMock.disable_net_connect!(allow_localhost: true)

    DatabaseCleaner.clean_with :truncation

    create(:taxonomy_term, name: 'Tooo')
    create(:taxonomy_term, name: 'Taaaaz')

    create(:plant_variety, plant_variety_name: "Pvoo")
    create(:plant_variety, plant_variety_name: "Pvoobar")
    create(:plant_variety, plant_variety_name: "Pvoobarbaz")

    create(:plant_line, plant_line_name: "Ploo",
                        common_name: "Ploo cabbage",
                        taxonomy_term: TaxonomyTerm.first)
    create(:plant_line, plant_line_name: "Ploobar",
                        common_name: "Ploobar cabbage",
                        taxonomy_term: TaxonomyTerm.second)
    create(:plant_line, plant_line_name: "Ploobarbaz",
                        common_name: "Ploobarbaz cabbage",
                        taxonomy_term: TaxonomyTerm.second)

    create(:plant_population, name: 'Ppoo',
                              taxonomy_term: TaxonomyTerm.first,
                              male_parent_line: nil,
                              female_parent_line: nil)
    create(:plant_population, name: 'Ppoobar',
                              taxonomy_term: TaxonomyTerm.second,
                              male_parent_line: nil,
                              female_parent_line: nil)
    create(:plant_population, name: 'Ppoobarbaz',
                              taxonomy_term: TaxonomyTerm.second,
                              male_parent_line: nil,
                              female_parent_line: nil)

    # FIXME without sleep ES is not able to update index in time
    sleep 1
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  describe "#plant_populations" do
    it "finds PP by its name" do
      expect(Search.new("Ppoo").plant_populations.count).to eq 3
      expect(Search.new("Ppoobar").plant_populations.count).to eq 2
      expect(Search.new("Ppoobarbaz").plant_populations.count).to eq 1
      expect(Search.new("Ppoobarbaz").plant_populations.first.id.to_i).
        to eq PlantPopulation.find_by!(name: 'Ppoobarbaz').id
    end

    it "finds PPs by taxonomy term name" do
      results = Search.new(TaxonomyTerm.first.name).plant_populations
      expect(results.count).to eq 1

      results = Search.new(TaxonomyTerm.second.name).plant_populations
      expect(results.count).to eq 2
    end
  end

  describe "#plant_varieties" do
    it "finds PV by :plant_variety_name" do
      expect(Search.new("Pvoo").plant_varieties.count).to eq 3
      expect(Search.new("Pvoobar").plant_varieties.count).to eq 2
      expect(Search.new("Pvoobarbaz").plant_varieties.count).to eq 1
      expect(Search.new("Pvoobarbaz").plant_varieties.first.id.to_i).
        to eq PlantVariety.find_by!(plant_variety_name: 'Pvoobarbaz').id
    end
  end

  describe "#plant_lines" do
    it "finds PL by :plant_line_name" do
      expect(Search.new("Ploo").plant_lines.count).to eq 3
      expect(Search.new("Ploobar").plant_lines.count).to eq 2
      expect(Search.new("Ploobarbaz").plant_lines.count).to eq 1
      expect(Search.new("Ploobarbaz").plant_lines.first.id.to_i).
        to eq PlantLine.find_by!(plant_line_name: 'Ploobarbaz').id
    end

    it "finds PL by fragment of :plant_line_name" do
      expect(Search.new("lo").plant_lines.count).to eq 3
      expect(Search.new("looba").plant_lines.count).to eq 2
      expect(Search.new("loobarba").plant_lines.count).to eq 1
      expect(Search.new("loobarbaz").plant_lines.first.id.to_i).
        to eq PlantLine.find_by!(plant_line_name: 'Ploobarbaz').id
    end

    it "finds PLs by taxonomy term name" do
      results = Search.new(TaxonomyTerm.first.name).plant_lines
      expect(results.count).to eq 1

      results = Search.new(TaxonomyTerm.second.name).plant_lines
      expect(results.count).to eq 2
    end
  end

  describe "#counts" do
    it "returns proper counts" do
      counts = Search.new("*").counts
      expect(counts[:plant_lines]).to eq PlantLine.count
      expect(counts[:plant_populations]).to eq PlantPopulation.count
      expect(counts[:plant_varieties]).to eq PlantVariety.count
    end
  end
end
