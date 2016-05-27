require "rails_helper"

RSpec.describe Submission::PlantTrialPublisher do
  let(:plant_trial) { submission.submitted_object }
  let(:user) { submission.user }

  subject { described_class.new(submission) }

  context "#publish" do
    let(:submission) { create(:finalized_submission, :trial) }
    let!(:plant_scoring_units) { [
      create(:plant_scoring_unit, published: false,
                                  user: user,
                                  plant_trial: plant_trial),
      create(:plant_scoring_unit, published: false, user: user)
    ] }
    let!(:trait_descriptors) { [
      create(:trait_descriptor, published: false, user: user),
      create(:trait_descriptor, published: false, user: user),
    ] }
    let!(:trait_scores) { [
      create(:trait_score, published: false, user: user,
                           plant_scoring_unit: plant_scoring_units[0],
                           trait_descriptor: trait_descriptors[0]),
      create(:trait_score, published: false, user: user,
                           plant_scoring_unit: plant_scoring_units[1],
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
      expect(trait_descriptors[0].reload).to be_published
    end

    it "does not modify objects not associated with given submission" do
      expect(plant_scoring_units[1].reload).not_to be_published
      expect(trait_descriptors[1].reload).not_to be_published
      expect(trait_scores[1].reload).not_to be_published
    end
  end

  context "#revoke" do
    let(:submission) { create(:finalized_submission, :trial, published: true) }

    context "for revocable submission" do
      let!(:plant_scoring_units) { [
        create(:plant_scoring_unit, published: true,
                                    user: user,
                                    plant_trial: plant_trial),
        create(:plant_scoring_unit, published: true, user: user)
      ] }
      let!(:trait_descriptors) { [
        create(:trait_descriptor, published: true, user: user),
        create(:trait_descriptor, published: true, user: user),
      ] }
      let!(:trait_scores) { [
        create(:trait_score, published: true, user: user,
                             plant_scoring_unit: plant_scoring_units[0],
                             trait_descriptor: trait_descriptors[0]),
        create(:trait_score, published: true, user: user,
                             plant_scoring_unit: plant_scoring_units[1],
                             trait_descriptor: trait_descriptors[1])
      ] }

      before { subject.revoke }

      it "revokes publication of submitted plant trial" do
        expect(submission.reload).not_to be_published
        expect(plant_trial.reload).not_to be_published
      end

      it "revokes publication of associated objects belonging to submission's owner" do
        expect(plant_scoring_units[0].reload).not_to be_published
        expect(trait_scores[0].reload).not_to be_published
        expect(trait_descriptors[0].reload).not_to be_published
      end

      it "does not modify objects not associated with given submission" do
        expect(plant_scoring_units[1].reload).to be_published
        expect(trait_descriptors[1].reload).to be_published
        expect(trait_scores[1].reload).to be_published
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
