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
      linkage_groups: 11,
      marker_assays: 1,
      primers: 2,
      probes: 3,
      plant_trials: 32,
      qtl: 1,
      trait_descriptors: 3,
      plant_scoring_units: 1
    } }


    it "shows counts" do
      assign(:counts, counts)
      render
      expect(rendered).to include "Found 7 plant lines"
      expect(rendered).to include "Found 135 plant populations"
      expect(rendered).to include "Found 171 plant varieties"
      expect(rendered).to include "Found 2 map locus hits"
      expect(rendered).to include "Found 1 map position"
      expect(rendered).not_to include "Found 0 population loci"
      expect(rendered).to include "Found 6 linkage maps"
      expect(rendered).to include "Found 11 linkage groups"
      expect(rendered).to include "Found 1 marker assay"
      expect(rendered).to include "Found 2 primers"
      expect(rendered).to include "Found 3 probes"
      expect(rendered).to include "Found 32 plant trials"
      expect(rendered).to include "Found 1 quantitative trait locus"
      expect(rendered).to include "Found 3 trait descriptors"
      expect(rendered).to include "Found 1 plant scoring unit"
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
