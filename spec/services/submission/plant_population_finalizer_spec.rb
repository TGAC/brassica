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
      attributes_for_list(:plant_line, 2).map.with_index { |attrs,i|
        attrs.slice(:plant_line_name, :sequence_identifier, :comments, :data_owned_by, :data_provenance).
          merge(
            taxonomy_term: taxonomy_term.name,
            plant_variety_name: (i == 0) ? plant_variety.plant_variety_name : 'New PV name'
          )
      }
    }

    let(:plant_population_attrs) { attributes_for(:plant_population) }

    before do
      submission.content.update(:step01,
                                plant_population_attrs.
                                  slice(:name, :description).
                                  merge(population_type: population_type.population_type))
      submission.content.update(:step02,
                                taxonomy_term: taxonomy_term.name,
                                female_parent_line: plant_lines[0].plant_line_name,
                                male_parent_line: plant_lines[1].plant_line_name)
      submission.content.update(:step03,
                                plant_line_list: [plant_lines[0].plant_line_name, new_plant_lines_attrs[0][:plant_line_name], new_plant_lines_attrs[1][:plant_line_name]],
                                new_plant_lines: new_plant_lines_attrs,
                                new_plant_varieties: {
                                  new_plant_lines_attrs[1][:plant_line_name] => {
                                    plant_variety_name: 'New PV name',
                                    crop_type: 'A crop of a type'
                                  }
                                },
                                new_plant_accessions: {
                                  new_plant_lines_attrs[0][:plant_line_name] => {
                                    plant_accession: 'New PA',
                                    originating_organisation: 'An organisation',
                                    year_produced: '2010'
                                  }
                                })
      submission.content.update(:step04,
                                plant_population_attrs.
                                  slice(:data_owned_by, :data_provenance, :comments).
                                  merge(visibility: 'published'))
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

    it 'does not require taxonomy term for plant population' do
      submission.content.update(:step02, taxonomy_term: '')
      subject.call
      expect(subject.plant_population.attributes).to include( "taxonomy_term_id" => nil )
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
      end
    end

    it 'assigns existing plant varieties and creates new ones' do
      expect { subject.call }.to change { PlantVariety.count }.by(1)
      expect(PlantLine.find_by(plant_line_name: new_plant_lines_attrs[0][:plant_line_name]).plant_variety).
        to eq PlantVariety.find_by(plant_variety_name: new_plant_lines_attrs[0][:plant_variety_name])
      expect(PlantLine.find_by(plant_line_name: new_plant_lines_attrs[1][:plant_line_name]).plant_variety).
        to eq PlantVariety.find_by(plant_variety_name: 'New PV name')
      expect(PlantVariety.find_by(plant_variety_name: 'New PV name').attributes).
        to include(
          'crop_type' => 'A crop of a type',
          'date_entered' => Date.today,
          'entered_by_whom' => submission.user.full_name,
          'user_id' => submission.user.id,
          'published' => true
        )
    end

    it 'creates new plant accessions where requested to' do
      expect { subject.call }.to change { PlantAccession.count }.by(1)
      expect(PlantAccession.find_by(plant_accession: 'New PA').attributes).
        to include(
          'originating_organisation' => 'An organisation',
          'year_produced' => '2010',
          'plant_variety_id' => nil,
          'plant_line_id' => PlantLine.find_by(plant_line_name: new_plant_lines_attrs[0][:plant_line_name]).id,
          'date_entered' => Date.today,
          'entered_by_whom' => submission.user.full_name,
          'user_id' => submission.user.id,
          'published' => true
        )
    end

    it 'rollbacks when encountered existing PA data' do
      create(:plant_accession,
             plant_accession: 'New PA',
             originating_organisation: 'An organisation',
             year_produced: '2010')
      expect{ subject.call }.not_to change{ PlantAccession.count }
      expect(submission.finalized?).to be_falsey
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
