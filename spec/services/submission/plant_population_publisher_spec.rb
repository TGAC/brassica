require "rails_helper"

RSpec.describe Submission::PlantPopulationPublisher do
  let(:plant_population) { submission.submitted_object }
  let(:user) { submission.user }

  subject { described_class.new(submission) }

  context "#publish" do
    let(:submission) { create(:finalized_submission, :population) }
    let!(:plant_lines) { create_list(:plant_line, 2, user: user, published: false) }
    let!(:plant_population_lists) { [
      create(:plant_population_list, plant_line: plant_lines[0],
                                     plant_population: plant_population,
                                     user: user, published: false),
      create(:plant_population_list, plant_line: plant_lines[1],
                                     user: user, published: false)
    ] }

    before { subject.publish }

    it "publishes submitted plant population" do
      expect(submission.reload).to be_publishable
      expect(plant_population.reload).to be_published
    end

    it "publishes associated objects" do
      expect(plant_population.plant_lines).to all(be_published)
      expect(plant_population.plant_population_lists).to all(be_published)
    end

    it "does not modify objects not associated with given submission" do
      expect(plant_population_lists[1].reload).not_to be_published
      expect(plant_lines[1].reload).not_to be_published
    end
  end

  context "#revoke" do
    let(:submission) { create(:finalized_submission, :population, publishable: true) }

    context "for revocable submission" do
      let!(:plant_lines) { [
        create(:plant_line, :not_owned_by_user, published: true),
        create(:plant_line, user: user, published: true),
        create(:plant_line, user: user, published: true)
      ] }
      let!(:plant_population_lists) { [
        create(:plant_population_list, plant_line: plant_lines[0],
                                       plant_population: plant_population,
                                       user: user, published: true),
        create(:plant_population_list, plant_line: plant_lines[1],
                                       plant_population: plant_population,
                                       user: user, published: true),
        create(:plant_population_list, plant_line: plant_lines[2],
                                       user: user, published: true)
      ] }

      before { subject.revoke }

      it "revokes publication of submitted plant population" do
        expect(submission.reload).not_to be_publishable
        expect(plant_population.reload).not_to be_published
      end

      it "revokes publication of associated objects belonging to submission's owner" do
        expect(plant_lines[1].reload).not_to be_published
        expect(plant_population_lists[0].reload).not_to be_published
        expect(plant_population_lists[1].reload).not_to be_published
      end

      it "does not modify objects not associated with given submission" do
        expect(plant_lines[2].reload).to be_published
        expect(plant_population_lists[2].reload).to be_published
      end

      it "does not modify objects not belonging to sumission's owner" do
        expect(plant_lines[0].reload).to be_published
      end
    end

    context "for irrevocable submission" do
      before do
        plant_population.update_column(:published_on, 7.days.ago)
      end

      it "fails" do
        expect { subject.revoke }.to raise_error(/not revocable/)
      end
    end
  end
end
