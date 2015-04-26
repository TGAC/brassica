require 'rails_helper'

RSpec.describe Search, :elasticsearch, :dont_clean_db do

  before(:all) do
    WebMock.disable_net_connect!(allow_localhost: true)

    create(:taxonomy_term, name: 'Tooo')
    create(:taxonomy_term, name: 'Taaaaz')

    create(:plant_population, name: 'Foo', taxonomy_term: TaxonomyTerm.first)
    create(:plant_population, name: 'Bar', taxonomy_term: TaxonomyTerm.second)
    create(:plant_population, name: 'Baz', taxonomy_term: TaxonomyTerm.second)

    # FIXME without sleep ES is not able to update index in time
    sleep 1
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  describe "#plant_populations" do
    let!(:plant_population) { PlantPopulation.all.sample }

    it "finds PP by its name" do
      results = Search.new(plant_population.name).plant_populations.results
      expect(results.count).to eq 1
      expect(results.first.name).to eq plant_population.name
    end

    it "finds PPs by taxonomy term name" do
      results = Search.new(TaxonomyTerm.first.name).plant_populations
      expect(results.count).to eq 1

      results = Search.new(TaxonomyTerm.second.name).plant_populations
      expect(results.count).to eq 2
    end
  end

  describe "#plant_varieties" do
    it "finds PV" do
      pending "test Search#plant_varieties"
      fail
    end
  end

  describe "#plant_lines" do
    it "finds PL" do
      pending "test Search#plant_lines"
      fail
    end
  end

  describe "#counts" do
    it "returns proper counts" do
      pending "test Search#counts"
      fail
    end
  end
end
