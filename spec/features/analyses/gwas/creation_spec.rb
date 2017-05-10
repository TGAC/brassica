require "features_helper"

RSpec.feature "Analysis creation" do
  let(:user) { create(:user) }
  let!(:plant_trial) { create(:plant_trial, user: user) }

  before { login_as(user, scope: :user) }

  let(:phenotype_data_file) { fixture_file("gwas-phenotype.csv", "text/csv") }
  let(:map_data_file) { fixture_file("gwas-map.csv", "text/csv") }

  before do
    visit new_analysis_path
  end

  context "with no input" do
    scenario "shows error messages" do
      click_link("Start!")
      click_button("Run")

      expect(page).to have_error("Please provide a name for analysis.")
      expect(page).to have_error("Please upload a genotype data file.")
      expect(page).to have_error("Please upload a phenotype data file.")
    end
  end

  context "with VCF genotype data" do
    scenario "is successful", js: true do
      click_link("Start!")
      fill_in("Analysis name", with: "Some interesting name")

      click_on "Data upload"

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
      click_link("Start!")
      fill_in("Analysis name", with: "Some interesting name")

      click_on "Data upload"

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

  context "with plant trial selected" do
    let!(:trait_descriptors) { create_list(:trait_descriptor, 5) }
    let!(:plant_scoring_units) {
      1.upto(100).map { |idx|
        create(:plant_scoring_unit, plant_trial: plant_trial, scoring_unit_name: "plant#{idx}")
      }
    }
    let!(:trait_scores) {
      plant_scoring_units.map.with_index { |psu, idx|
        create(:trait_score, plant_scoring_unit: psu, score_value: idx, trait_descriptor: trait_descriptors.sample)
      }
    }

    scenario "is successful", js: true do
      click_link("Start!")
      fill_in("Analysis name", with: "Some interesting name")

      select(plant_trial.plant_trial_name, from: "analysis_plant_trial_id")

      attach_file("genotype-data-file", fixture_file_path("gwas-genotypes.csv"))
      attach_file("map-data-file", fixture_file_path("gwas-map.csv"))

      sleep(1)

      expect {
        click_button "Run"
      }.to change { Analysis.count }.from(0).to(1)

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
