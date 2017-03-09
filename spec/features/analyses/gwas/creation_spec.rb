require "features_helper"

RSpec.feature "Analysis creation" do
  let(:user) { create(:user) }

  before { login_as(user, scope: :user) }

  let(:phenotype_data_file) { fixture_file("gwas-phenotype.csv", "text/csv") }
  let(:map_data_file) { fixture_file("gwas-map.csv", "text/csv") }

  before do
    visit new_analysis_path
    click_link("Start!")
  end

  context "with no input" do
    scenario "shows error messages" do
      click_button("Run")

      expect(page).to have_error("Please provide a name for analysis.")
      expect(page).to have_error("Please upload a genotype data file.")
      expect(page).to have_error("Please upload a phenotype data file.")
    end
  end

  context "with VCF genotype data" do
    scenario "is successful", js: true do
      fill_in("Analysis name", with: "Some interesting name")

      attach_file("genotype-data-file", fixture_file_path("gwas-genotypes.vcf"))
      attach_file("phenotype-data-file", fixture_file_path("gwas-phenotypes.csv"))

      sleep(1)

      expect { click_button "Run" }.to change { Analysis.count }.from(0).to(1)

      expect(page).to have_current_path(analyses_path)
      expect(page).to have_content("Some interesting name")
    end
  end

  context "with CSV genotype data" do
    scenario "is successful", js: true do
      fill_in("Analysis name", with: "Some interesting name")

      attach_file("genotype-data-file", fixture_file_path("gwas-genotypes.csv"))
      attach_file("map-data-file", fixture_file_path("gwas-map.csv"))
      attach_file("phenotype-data-file", fixture_file_path("gwas-phenotypes.csv"))

      sleep(1)

      expect { click_button "Run" }.to change { Analysis.count }.from(0).to(1)

      expect(page).not_to have_content("Please upload a genotype data file.")
      expect(page).not_to have_content("Please upload a phenotype data file.")

      expect(page).to have_current_path(analyses_path)
      expect(page).to have_content("Some interesting name")
    end
  end

  def attach_file(dom_id, path, options = {})
    page.execute_script("$('##{dom_id}').css({ opacity: 100, position: 'static' })")

    super(dom_id, path, options)

    page.execute_script("$('##{dom_id}').parents('form').remove()")
  end
end
