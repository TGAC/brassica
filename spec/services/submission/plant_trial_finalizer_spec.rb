require 'rails_helper'

RSpec.describe Submission::PlantTrialFinalizer do

  let(:submission) { create(:submission, :trial) }
  let(:plant_population) { create(:plant_population, user: submission.user) }
  let(:old_trait_descriptor) { create(:trait_descriptor) }

  subject { described_class.new(submission) }

  context 'given submission with valid content' do
    let(:plant_trial_attrs) {
      attributes_for(:plant_trial).merge(plant_population_id: plant_population.id)
    }
    let(:new_trait_descriptors_attrs) {
      attributes_for_list(:trait_descriptor, 2)
    }

    before do
      submission.content.update(:step01, plant_trial_attrs)
      submission.content.update(:step02,
        trait_descriptor_list: new_trait_descriptors_attrs.map{ |td| td[:descriptor_name] } + [old_trait_descriptor.id],
        new_trait_descriptors: new_trait_descriptors_attrs)
      submission.content.update(:step03,
        trait_mapping: { 0 => 2, 1 => 1, 2 => 0 },
        trait_scores: {
          'p1' => {},
          'p2' => { 1 => 'x' },
          'p3' => { 0 => 'y', 2 => 'z' },
          'p4' => { 2 => '' }
        }
      )
      submission.content.update(:step04, plant_trial_attrs.slice(
        :data_owned_by, :data_provenance, :comments).merge(visibility: 'published'))
    end

    it 'creates new trait descriptors' do
      expect{ subject.call }.to change{ TraitDescriptor.count }.by(2)

      expect(subject.new_trait_descriptors.size).to eq 2
      subject.new_trait_descriptors.each_with_index do |trait_descriptor, idx|
        expect(trait_descriptor).to be_persisted
        expect(trait_descriptor.attributes).to include(
          'descriptor_name' => new_trait_descriptors_attrs[idx][:descriptor_name],
          'category' => new_trait_descriptors_attrs[idx][:category],
          'likely_ambiguities' => new_trait_descriptors_attrs[idx][:likely_ambiguities],
          'entered_by_whom' => submission.user.full_name,
          'date_entered' => Date.today,
          'published' => true,
          'user_id' => submission.user.id
        )
        expect(trait_descriptor.published_on).to be_within(5.seconds).of(Time.now)
      end
    end

    it 'creates plant trial' do
      expect{ subject.call }.to change{ PlantTrial.count }.by(1)

      expect(PlantTrial.last.plant_trial_name).to eq plant_trial_attrs[:plant_trial_name]
      expect(PlantTrial.last.comments).to eq plant_trial_attrs[:comments]
      expect(PlantTrial.last.entered_by_whom).to eq submission.user.full_name
      expect(PlantTrial.last.date_entered).to eq Date.today
      expect(PlantTrial.last.published).to be_truthy
      expect(PlantTrial.last.user).to eq submission.user
      expect(PlantTrial.last.published_on).to be_within(5.seconds).of(Time.now)
    end

    it 'associates created plant trial with plant population' do
      subject.call

      expect(PlantTrial.last.plant_population).to eq plant_population
    end

    it 'creates plant scoring units' do
      expect{ subject.call }.to change{ PlantScoringUnit.count }.by(4)

      expect(PlantScoringUnit.pluck(:scoring_unit_name)).to match_array %w(p1 p2 p3 p4)
      expect(PlantScoringUnit.pluck(:entered_by_whom).uniq).to eq [submission.user.full_name]
      expect(PlantScoringUnit.pluck(:plant_trial_id).uniq).to eq [plant_population.plant_trials.first.id]
    end

    it 'creates trait scores for adequate trait descriptors' do
      expect{ subject.call }.to change{ TraitScore.count }.by(3)

      expect(TraitScore.pluck(:score_value)).to match_array %w(x y z)
      expect(TraitScore.pluck(:entered_by_whom).uniq).to eq [submission.user.full_name]
      expect(TraitScore.find_by(score_value: 'x').trait_descriptor.descriptor_name).
        to eq new_trait_descriptors_attrs[1][:descriptor_name]
      expect(TraitScore.find_by(score_value: 'x').plant_scoring_unit.scoring_unit_name).to eq 'p2'
      expect(TraitScore.find_by(score_value: 'y').trait_descriptor.descriptor_name).
        to eq old_trait_descriptor.descriptor_name
      expect(TraitScore.find_by(score_value: 'y').plant_scoring_unit.scoring_unit_name).to eq 'p3'
      expect(TraitScore.find_by(score_value: 'z').trait_descriptor.descriptor_name).
        to eq new_trait_descriptors_attrs[0][:descriptor_name]
      expect(TraitScore.find_by(score_value: 'z').plant_scoring_unit.scoring_unit_name).to eq 'p3'
    end

    it 'makes submission and created objects published' do
      subject.call

      expect(TraitDescriptor.all).to all be_published
      expect(TraitScore.all).to all be_published
      expect(PlantScoringUnit.all).to all be_published
      expect(PlantTrial.all).to all be_published
      expect(submission).to be_published
    end

    context 'when visibility set to private' do
      before do
        submission.content.update(:step04, visibility: 'private')
      end

      it 'makes submission and created objects private' do
        subject.call

        plant_trial = submission.submitted_object
        plant_scoring_units = plant_trial.plant_scoring_units
        trait_scores = plant_trial.plant_scoring_units.map(&:trait_scores).flatten

        expect(submission).not_to be_published
        expect(plant_trial).not_to be_published
        expect(plant_scoring_units.map(&:published?)).to all be_falsey
        expect(trait_scores.map(&:published?)).to all be_falsey
      end
    end

    context 'when encountered broken data' do
      it 'rollbacks when no Population is found' do
        plant_population.destroy
        expect{ subject.call }.to change{ related_object_count }.by(0)
        expect(submission.finalized?).to be_falsey
      end

      it 'rollbacks when no Trait Descriptor is found' do
        old_trait_descriptor.destroy
        expect{ subject.call }.to change{ related_object_count }.by(0)
        expect(submission.finalized?).to be_falsey
      end

      def related_object_count
        PlantTrial.count + TraitScore.count + PlantScoringUnit.count + TraitDescriptor.count
      end
    end
  end
end
