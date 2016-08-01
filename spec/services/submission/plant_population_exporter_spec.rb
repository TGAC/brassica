require "rails_helper"

RSpec.describe Submission::PlantPopulationExporter do
  let(:submission) { create(:finalized_submission, :population, published: true) }
  let(:plant_population) { submission.submitted_object }
  let(:plant_lines) { create_list(:plant_line, 2, plant_variety: create(:plant_variety)) }

  subject { described_class.new(submission) }

  describe "#documents" do
    it 'produces properly formatted all plant submission CSV documents' do
      create(:plant_population_list, plant_line: plant_lines[0],
                                     plant_population: plant_population)
      create(:plant_population_list, plant_line: plant_lines[1],
                                     plant_population: plant_population)
      male_parent_line = create(:plant_line, fathered_descendants: [plant_population],
                                             plant_variety: create(:plant_variety))
      create(:plant_line, mothered_descendants: [plant_population],
                          plant_variety: create(:plant_variety))

      documents = subject.documents

      expect(documents.size).to eq 5
      expect(documents[:plant_population].lines.size).to eq 2
      expect(documents[:plant_population].lines[1].chomp).
        to end_with plant_population.description
      expect(documents[:plant_varieties].lines.size).to eq 4
      expect(documents[:plant_varieties].lines[1,3].map{ |l| l.split(',')[0] }).
        to match_array PlantVariety.all.pluck(:plant_variety_name)
      expect(documents[:plant_lines].lines.size).to eq 3
      expect(documents[:plant_lines].lines[1,2].map{ |l| l.split(',')[1] }).
        to match_array plant_lines.map(&:plant_line_name)
      expect(documents[:female_parent_line].lines.size).to eq 2
      expect(documents[:female_parent_line].lines[0]).
        to start_with 'taxonomy_terms.name'
      expect(documents[:male_parent_line].lines.size).to eq 2
      expect(documents[:male_parent_line].lines[1].split(',')[1]).
        to eq male_parent_line.plant_line_name
    end

    it 'produces no documents for no-data cases' do
      documents = subject.documents
      expect(documents.size).to eq 1
    end

    it 'handles commas appropriately' do
      plant_population.update_attribute(:name, 'With,comma')
      documents = subject.documents
      expect(documents.size).to eq 1
      expect(documents[:plant_population].lines.size).to eq 2
      expect(documents[:plant_population].lines[1]).
        to include '"With,comma"'
    end

    it 'exports plant varieties for parent lines in absence of population lists' do
      create(:plant_line, fathered_descendants: [plant_population],
                          plant_variety: create(:plant_variety))
      documents = subject.documents
      expect(documents.size).to eq 3
      expect(documents[:plant_varieties].lines.size).to eq 2
      expect(documents[:plant_lines]).to be_nil
      expect(documents[:male_parent_line].lines.size).to eq 2
    end
  end
end
