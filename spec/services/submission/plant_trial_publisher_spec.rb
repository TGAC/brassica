require "rails_helper"

RSpec.describe Submission::PlantTrialPublisher do
  let(:plant_trial) { submission.submitted_object }
  let(:user) { submission.user }

  subject { described_class.new(submission) }

  context "#publish" do
    let(:submission) { create(:finalized_submission, :trial) }
    let(:plant_line) { create(:plant_line, published: false, user: user) }
    let(:plant_variety) { create(:plant_variety, published: false, user: user) }
    let(:plant_accessions) { [
      create(:plant_accession, published: false, user: user, plant_line: plant_line),
      create(:plant_accession, published: false, user: user, plant_variety: plant_variety, plant_line: nil)
    ] }
    let(:plant_scoring_units) { [
      create(:plant_scoring_unit, published: false,
                                  user: user,
                                  plant_trial: plant_trial,
                                  plant_accession: plant_accessions[0]),
      create(:plant_scoring_unit, published: false,
                                  user: user,
                                  plant_trial: plant_trial,
                                  plant_accession: plant_accessions[1]),
      create(:plant_scoring_unit, published: false,
                                  user: user,
                                  plant_accession: plant_accessions[1])
    ] }
    let(:trait_descriptors) { [
      create(:trait_descriptor, published: false, user: user),
      create(:trait_descriptor, published: false, user: user),
    ] }
    let!(:trait_scores) { [
      create(:trait_score, published: false, user: user,
                           plant_scoring_unit: plant_scoring_units[0],
                           trait_descriptor: trait_descriptors[0]),
      create(:trait_score, published: false, user: user,
                           plant_scoring_unit: plant_scoring_units[2],
                           trait_descriptor: trait_descriptors[1])
    ] }

    before { subject.publish }

    it "publishes submitted plant trial" do
      expect(submission.reload).to be_published
      expect(plant_trial.reload).to be_published
    end

    it "publishes associated objects" do
      expect(plant_trial.plant_scoring_units).to all(be_published)
      expect(plant_trial.plant_scoring_units.map(&:trait_scores).flatten).to all(be_published)
      expect(plant_trial.plant_scoring_units.map(&:plant_accession)).to all(be_published)
      expect(plant_variety.reload).to be_published
      expect(plant_line.reload).to be_published
      expect(trait_descriptors[0].reload).to be_published
    end

    it "does not modify objects not associated with given submission" do
      expect(plant_scoring_units[2].reload).not_to be_published
      expect(trait_descriptors[1].reload).not_to be_published
      expect(trait_scores[1].reload).not_to be_published
    end
  end

  context "#revoke" do
    let(:submission) { create(:finalized_submission, :trial, published: true) }

    context "for revocable submission" do
      let(:owned_plant_line) { create(:plant_line, published: true, user: user) }
      let(:public_plant_line) { create(:plant_line) }
      let(:owned_plant_variety) { create(:plant_variety, published: true, user: user) }
      let(:public_plant_variety) { create(:plant_variety) }
      let(:owned_accessions) { [
        create(:plant_accession, published: true, user: user, plant_line: owned_plant_line),
        create(:plant_accession, published: true, user: user, plant_line: public_plant_line),
        create(:plant_accession, published: true, user: user, plant_line: nil, plant_variety: owned_plant_variety),
        create(:plant_accession, published: true, user: user, plant_line: nil, plant_variety: public_plant_variety)
      ] }
      let(:public_accession) { create(:plant_accession) }
      let(:plant_scoring_units) { [
        create(:plant_scoring_unit, published: true, user: user, plant_trial: plant_trial, plant_accession: owned_accessions[0]),
        create(:plant_scoring_unit, published: true, user: user, plant_trial: plant_trial, plant_accession: owned_accessions[1]),
        create(:plant_scoring_unit, published: true, user: user, plant_trial: plant_trial, plant_accession: owned_accessions[2]),
        create(:plant_scoring_unit, published: true, user: user, plant_trial: plant_trial, plant_accession: owned_accessions[3]),
        create(:plant_scoring_unit, published: true, user: user, plant_trial: plant_trial, plant_accession: public_accession),
        create(:plant_scoring_unit, published: true, user: user, plant_accession: public_accession)
      ] }
      let(:trait_descriptors) { [
        create(:trait_descriptor, published: true, user: user),
        create(:trait_descriptor, published: true, user: user),
      ] }
      let!(:trait_scores) { [
        create(:trait_score, published: true, user: user,
                             plant_scoring_unit: plant_scoring_units[0],
                             trait_descriptor: trait_descriptors[0]),
        create(:trait_score, published: true, user: user,
                             plant_scoring_unit: plant_scoring_units.last,
                             trait_descriptor: trait_descriptors[1])
      ] }

      before { subject.revoke }

      it "revokes publication of submitted plant trial" do
        expect(submission.reload).not_to be_published
        expect(plant_trial.reload).not_to be_published
      end

      it "revokes publication of associated objects belonging to submission's owner" do
        plant_scoring_units[0..-2].each do |plant_scoring_unit|
          expect(plant_scoring_unit.reload).not_to be_published
        end
        expect(trait_scores[0].reload).not_to be_published
        expect(trait_descriptors[0].reload).not_to be_published
        owned_accessions.each do |owned_accession|
          expect(owned_accession.reload).not_to be_published
        end
        expect(owned_plant_line.reload).not_to be_published
        expect(owned_plant_variety.reload).not_to be_published
      end

      it "does not modify objects not associated with given submission" do
        expect(plant_scoring_units.last.reload).to be_published
        expect(trait_descriptors[1].reload).to be_published
        expect(trait_scores[1].reload).to be_published
        expect(public_accession.reload).to be_published
        expect(public_plant_line.reload).to be_published
        expect(public_plant_variety.reload).to be_published
      end
    end

    context "for irrevocable submission" do
      before do
        plant_trial.update_column(:published_on, 7.days.ago)
      end

      it "fails" do
        expect { subject.revoke }.to raise_error(/not revocable/)
      end
    end
  end
end
