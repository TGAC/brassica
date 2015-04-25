require 'rails_helper'

RSpec.describe "searches/counts.html.haml" do
  context "with some results found" do
    let(:counts) { {
      plant_lines: 7,
      plant_populations: 135,
      plant_varieties: 171,
    } }


    it "shows counts" do
      assign(:counts, counts)
      render
      expect(rendered).to include "Found 7 plant lines"
      expect(rendered).to include "Found 135 plant populations"
      expect(rendered).to include "Found 171 plant varieties"
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
