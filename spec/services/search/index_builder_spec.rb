require "rails_helper"

RSpec.describe Search::IndexBuilder, :elasticsearch do
  context "with already indexed records" do
    before(:all) do
      create(:plant_trial, plant_trial_name: "Foobar", published: true)

      refresh_index(PlantTrial)

      # Using #delete_all, not #destroy_all, so that index is not touched
      PlantTrial.delete_all
    end

    it "clears already indexed records" do
      expect { subject.call(PlantTrial) }.to \
        change { PlantTrial.search("Foobar").count }.
        from(1).to(0)
    end
  end

  context "with published records" do
    before(:all) do
      create(:plant_trial, plant_trial_name: "Foobar", published: true)

      delete_index(PlantTrial)
      create_index(PlantTrial)
      refresh_index(PlantTrial)
    end

    it "indexes published records" do
      expect { subject.call(PlantTrial) }.to \
        change { PlantTrial.search("Foobar").count }.
        from(0).to(1)
    end
  end

  context "with private records" do
    before(:all) do
      create(:plant_trial, plant_trial_name: "Foobar", published: false, published_on: nil)

      delete_index(PlantTrial)
      create_index(PlantTrial)
      refresh_index(PlantTrial)
    end

    it "does not index private records" do
      expect { subject.call(PlantTrial) }.not_to \
        change { PlantTrial.search("Foobar").count }

      expect(PlantTrial.search("Foobar").count).to eq(0)
    end
  end
end
