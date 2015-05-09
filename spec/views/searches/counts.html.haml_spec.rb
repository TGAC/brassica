require 'rails_helper'

RSpec.describe "searches/counts.html.haml" do
  context "with some results found" do
    let(:counts) { {
      plant_lines: 7,
      plant_populations: 135,
      plant_varieties: 171,
      map_locus_hits: 2,
      map_positions: 1,
      population_loci: 0,
      linkage_maps: 6,
      linkage_groups: 11
    } }


    it "shows counts" do
      assign(:counts, counts)
      render
      expect(rendered).to include "Found 7 plant lines"
      expect(rendered).to include "Found 135 plant populations"
      expect(rendered).to include "Found 171 plant varieties"
      expect(rendered).to include "Found 2 map locus hits"
      expect(rendered).to include "Found 1 map positions"
      expect(rendered).not_to include "Found 0 population loci"
      expect(rendered).to include "Found 6 linkage maps"
      expect(rendered).to include "Found 11 linkage groups"
    end
  end

  context "with no results found" do
    it "shows message" do
      assign(:counts, {})
      render
      expect(rendered).to include "No results found"
    end
  end
end
