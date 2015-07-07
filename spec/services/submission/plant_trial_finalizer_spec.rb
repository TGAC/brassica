require 'rails_helper'

RSpec.describe Submission::PlantTrialFinalizer do

  let(:submission) { create(:submission, :trial) }
  let(:plant_population) { create(:plant_population, user: submission.user) }

  subject { described_class.new(submission) }

  context 'given submission with valid content' do
    let(:plant_trial_attrs) { attributes_for(:plant_trial).merge(
      plant_population_id: plant_population.id
    ) }
    let(:new_trait_descriptors_attrs) {
      attributes_for_list(:trait_descriptor, 2).map { |attrs|
        attrs.slice(:descriptor_name, :category)
      }
    }

    before do
      submission.content.update(:step01, plant_trial_attrs.slice(
        :plant_trial_name, :project_descriptor, :plant_population_id,
        :country_id))
      submission.content.update(:step02,
        new_trait_descriptors: new_trait_descriptors_attrs)
      submission.content.update(:step03, {})
      submission.content.update(:step04, plant_trial_attrs.slice(
        :data_owned_by, :data_provenance, :comments))
    end

    it 'creates new trait descriptors' do
      subject.call

      expect(subject.new_trait_descriptors.size).to eq 2
      subject.new_trait_descriptors.each_with_index do |trait_descriptor, idx|
        expect(trait_descriptor).to be_persisted
        expect(trait_descriptor.attributes).to include(
          'descriptor_name' => new_trait_descriptors_attrs[idx][:descriptor_name],
          'category' => new_trait_descriptors_attrs[idx][:category]
        )
      end
    end
  end
end
