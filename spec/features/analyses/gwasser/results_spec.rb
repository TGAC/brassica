require "features_helper"

RSpec.feature "GWASSER results" do
  let(:user) { create(:user) }
  let(:analysis) { create(:analysis, :gwasser_with_results, status: :success, owner: user) }

  let!(:std_out) {
    create(:analysis_data_file, :std_out, owner: user, analysis: analysis, file: std_out_content)
  }
  let!(:std_err) {
    create(:analysis_data_file, :std_err, owner: user, analysis: analysis, file: std_err_content)
  }

  let!(:gwas_genotype) { create(:analysis_data_file, :gwas_genotype_csv, owner: user, analysis: analysis) }
  let!(:gwas_phenotype) { create(:analysis_data_file, :gwas_phenotype, owner: user, analysis: analysis) }
  let!(:gwas_map) { create(:analysis_data_file, :gwas_map, owner: user, analysis: analysis, file: gwas_map_content) }

  let(:gwas_map_content) { tempfile("ID,Chr,cM\nsnp1,1,14\nsnp2,2,4\nsnp3,1,3", ["gwas-map", ".csv"]) }
  let(:std_out_content) { tempfile("Some standard output text", ["std-out", ".txt"]) }
  let(:std_err_content) { tempfile("", ["std-err", ".txt"]) }

  before { login_as(user, scope: :user) }

  scenario "are available", js: true do
    visit analysis_path(analysis)

    expect(page).to have_content("GWASSER analysis: #{analysis.name}")
    expect(page).to have_css("#analysis_results.tab-pane.active")

    within("#analysis_results.tab-pane") do
      expect(page).to have_css("#gwas-manhattan-plot.js-plotly-plot")

      within("table.dataTable tbody") do
        expect(page).to have_css("tr", count: 9)
      end
    end

    click_link("Data files")

    within("#analysis_data_files.tab-pane") do
      within(".input-panel") do
        expect(page).to have_css("a", text: /gwas-genotypes.*\.csv/)
        expect(page).to have_css("a", text: /gwas-map.*\.csv/)
        expect(page).to have_css("a", text: /gwas-phenotypes.*\.csv/)
      end

      within(".output-panel") do
        analysis.data_files.gwas_results.each do |data_file|
          expect(page).to have_css("a", text: data_file.file_file_name)
        end
      end
    end

    click_link("Std output")

    within("#analysis_std_out") do
      expect(page).to have_css(".std-out pre", text: "Some standard output text")
    end

    click_link("Std error")

    within("#analysis_std_err") do
      expect(page).to have_css(".alert", text: "Standard error empty")
    end
  end
end

