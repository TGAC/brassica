require 'rails_helper'

RSpec.describe Submission::PlantPopulationFinalizer do

  let(:submission) { create(:submission) }
  let!(:plant_lines) { create_list(:plant_line, 2) }
  let!(:taxonomy_term) { create(:taxonomy_term) }
  let!(:population_type) { create(:population_type) }

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
                                name: "...name...",
                                description: "...description...",
                               )
      submission.content.update(:step02,
                                population_type: population_type.population_type,
                                taxonomy_term: taxonomy_term.name)
      submission.content.update(:step03,
                                plant_line_list: [plant_lines[0].plant_line_name, new_plant_lines[0][:plant_line_name], new_plant_lines[1][:plant_line_name]],
                                new_plant_lines: new_plant_lines,
                                female_parent_line: plant_lines[0].plant_line_name,
                                male_parent_line: plant_lines[1].plant_line_name)
      submission.content.update(:step04,
                                data_provenance: "...data provenance...")
    end

    it 'creates plant population' do
      subject.call
      expect(subject.plant_population).to be_persisted
      expect(subject.plant_population.attributes).to include(
        'name' => "...name...",
        'description' => "...description...",
        "data_provenance" => "...data provenance...",
        "population_type_id" => population_type.id,
        "taxonomy_term_id" => taxonomy_term.id,
        "female_parent_line_id" => plant_lines[0].id,
        "male_parent_line_id" => plant_lines[1].id
      )
      expect(subject.plant_population.plant_lines.map(&:plant_line_name)).
        to eq([plant_lines[0].plant_line_name] + new_plant_lines.map { |attrs| attrs[:plant_line_name] })
    end

    it 'creates new plant lines' do
      subject.call
      expect(subject.new_plant_lines.size).to eq 2
      subject.new_plant_lines.each_with_index do |plant_line, idx|
        expect(plant_line).to be_persisted
        expect(plant_line.plant_line_name).to eq new_plant_lines[idx][:plant_line_name]
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
