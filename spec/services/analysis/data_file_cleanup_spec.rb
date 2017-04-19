require "rails_helper"

RSpec.describe Analysis::DataFileCleanup do
  let(:user) { create(:user) }
  let(:analysis) { create(:analysis, owner: user) }

  context "orphaned data file" do
    let!(:orphaned_data_file) { create(:analysis_data_file, :gwas_phenotype, owner: user) }

    before { travel(1.month) }

    it "removes data file" do
      expect { subject.call }.to change { Analysis::DataFile.count }.from(1).to(0)
    end
  end

  context "assigned file" do
    let!(:assigned_data_file) { create(:analysis_data_file, :gwas_phenotype, owner: user, analysis: analysis) }

    before { travel(1.month) }

    it "preserves assigned data files" do
      expect { subject.call }.not_to change { Analysis::DataFile.count }
    end
  end
end
