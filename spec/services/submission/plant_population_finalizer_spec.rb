require 'rails_helper'

RSpec.describe Submission::PlantPopulationFinalizer do

  let(:submission) { create(:submission) }
  let!(:plant_lines) { create_list(:plant_line, 2) }
  let!(:taxonomy_term) { create(:taxonomy_term) }
  let!(:population_type_lookup) { create(:population_type_lookup) }

  subject { described_class.new(submission) }

  context 'given submission with valid content' do
    let(:new_plant_lines) { [
      {
        plant_line_name: "ABC",
        taxonomy_term: taxonomy_term.name
      }, {
        plant_line_name: "DEF",
        taxonomy_term: taxonomy_term.name
      }
    ] }

    before do
      submission.content.update(:step01,
                                name: "Experimental population",
                                description: "...", # FIXME must be not null, should be required in form?
                               )
      submission.content.update(:step02, population_type: PopulationTypeLookup.population_types.sample)
      submission.content.update(:step03,
                                plant_line_list: [plant_lines[0].plant_line_name, new_plant_lines[0][:plant_line_name], new_plant_lines[1][:plant_line_name]],
                                new_plant_lines: new_plant_lines,
                                female_parent_line: plant_lines[0].plant_line_name, # FIXME must be not null, should be required in form?
                                male_parent_line: plant_lines[1].plant_line_name) # FIXME must be not null, should be required in form?
      submission.content.update(:step04,
                                data_provenance: "...") # FIXME must be not null, should be required in form?
    end

    it 'creates plant population' do
      subject.call
      expect(subject.plant_population).to be_persisted
    end

    it 'creates new plant lines' do
      subject.call
      expect(subject.new_plant_lines.size).to eq 2
      subject.new_plant_lines.each do |plant_line|
        expect(plant_line).to be_persisted
      end
    end

    it 'crates plant population lists' do
      subject.call
      expect(subject.plant_population_lists.size).to eq 3
      subject.plant_population_lists.each do |plant_population_list|
        expect(plant_population_list).to be_persisted
      end
    end
  end
end
