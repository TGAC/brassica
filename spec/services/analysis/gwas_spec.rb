require "rails_helper"

RSpec.describe Analysis::Gwas do
  let(:analysis) { create(:analysis, :gwas) }

  subject { described_class.new(analysis) }

  describe "#call" do
    let(:selected_traits) { analysis.args.fetch("phenos") }

    it "stores output files for selected traits" do
      expect { subject.call }.
        to change { analysis.data_files.gwas_results.count }.
        from(0).to(selected_traits.length)

      expect(analysis.data_files.gwas_results.map { |r| r.file.original_filename }).
        to match_array(selected_traits.map { |t| "SNPAssociation-Full-#{t}.csv" })
    end
  end
end
