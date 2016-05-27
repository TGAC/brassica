require 'rails_helper'

RSpec.describe Submission::PlantPopulationFinalizer do

  let(:submission) { create(:submission, :population) }
  let!(:plant_lines) { create_list(:plant_line, 2) }
  let!(:taxonomy_term) { create(:taxonomy_term) }
  let!(:population_type) { create(:population_type) }
  let!(:plant_variety) { create(:plant_variety) }

  subject { described_class.new(submission) }

  context 'given submission with valid content' do
    let(:new_plant_lines_attrs) {
      attributes_for_list(:plant_line, 2).map { |attrs|
        attrs.slice(:plant_line_name, :sequence_identifier, :comments, :data_owned_by, :data_provenance).
          merge(taxonomy_term: taxonomy_term.name, plant_variety_name: plant_variety.plant_variety_name)
      }
    }

    let(:plant_population_attrs) { attributes_for(:plant_population) }

    before do
      submission.content.update(:step01, plant_population_attrs.slice(:name, :description))
      submission.content.update(:step02,
                                population_type: population_type.population_type,
                                taxonomy_term: taxonomy_term.name)
      submission.content.update(:step03,
                                plant_line_list: [plant_lines[0].plant_line_name, new_plant_lines_attrs[0][:plant_line_name], new_plant_lines_attrs[1][:plant_line_name]],
                                new_plant_lines: new_plant_lines_attrs,
                                female_parent_line: plant_lines[0].plant_line_name,
                                male_parent_line: plant_lines[1].plant_line_name)
      submission.content.update(:step04, plant_population_attrs.
        slice(:data_owned_by, :data_provenance, :comments).merge(visibility: 'published'))
    end

    it 'creates plant population' do
      subject.call
      expect(subject.plant_population).to be_persisted
      expect(subject.plant_population.attributes).to include(
        'name' => plant_population_attrs[:name],
        'description' => plant_population_attrs[:description],
        "data_provenance" => plant_population_attrs[:data_provenance],
        "data_owned_by" => plant_population_attrs[:data_owned_by],
        'date_entered' => Date.today,
        'entered_by_whom' => submission.user.full_name,
        "comments" => plant_population_attrs[:comments],
        "population_type_id" => population_type.id,
        "taxonomy_term_id" => taxonomy_term.id,
        "female_parent_line_id" => plant_lines[0].id,
        "male_parent_line_id" => plant_lines[1].id,
        'published' => true,
        'user_id' => submission.user.id
      )
      expect(subject.plant_population.published_on).to be_within(5.seconds).of(Time.now)
      expect(subject.plant_population.plant_lines.map(&:plant_line_name)).
        to match_array [plant_lines[0].plant_line_name] + new_plant_lines_attrs.map { |attrs| attrs[:plant_line_name] }
    end

    it 'records created plant population for later use' do
      subject.call
      expect(submission.submitted_object_id).to eq subject.plant_population.id
    end

    it 'assigns correct user as the owner of the population' do
      subject.call
      expect(submission.user).to eq subject.plant_population.user
    end

    it 'creates new plant lines' do
      subject.call
      expect(subject.new_plant_lines.size).to eq 2
      subject.new_plant_lines.each_with_index do |plant_line, idx|
        expect(plant_line).to be_persisted
        expect(plant_line.attributes).to include(
          'plant_line_name' => new_plant_lines_attrs[idx][:plant_line_name],
          'sequence_identifier' => new_plant_lines_attrs[idx][:sequence_identifier],
          'entered_by_whom' => submission.user.full_name,
          'date_entered' => Date.today,
          'data_owned_by' => new_plant_lines_attrs[idx][:data_owned_by],
          'data_provenance' => new_plant_lines_attrs[idx][:data_provenance],
          'comments' => new_plant_lines_attrs[idx][:comments],
          'published' => true,
          'user_id' => submission.user.id
        )
        expect(plant_line.published_on).to be_within(5.seconds).of(Time.now)
        expect(plant_line.plant_variety).to eq plant_variety
      end
    end

    it 'assigns correct user as the owner of created plant lines' do
      subject.call
      expect(subject.new_plant_lines.map(&:user)).to all eq submission.user
    end

    it 'crates plant population lists' do
      subject.call
      expect(subject.plant_population_lists.size).to eq 3
      subject.plant_population_lists.each do |plant_population_list|
        expect(plant_population_list).to be_persisted
        expect(plant_population_list.attributes).to include(
          'entered_by_whom' => submission.user.full_name,
          'date_entered' => Date.today,
          'published' => true,
          'user_id' => submission.user.id
        )
        expect(plant_population_list.published_on).to be_within(5.seconds).of(Time.now)
      end
    end


    it 'makes submission and created objects published' do
      subject.call

      expect(submission).to be_published
      expect(PlantLine.all).to all be_published
      expect(PlantPopulation.all).to all be_published
      expect(PlantPopulationList.all).to all be_published
    end

    context 'when visibility set to private' do
      before do
        submission.content.update(:step04, visibility: 'private')
      end

      it 'makes submission and created objects private' do
        subject.call

        plant_population = submission.submitted_object
        plant_population_lists = plant_population.plant_population_lists
        plant_lines = subject.new_plant_lines

        expect(submission).not_to be_published
        expect(plant_population).not_to be_published
        expect(plant_population_lists.map(&:published?)).to all be_falsey
        expect(plant_lines.map(&:published?)).to all be_falsey
      end
    end
  end
end
