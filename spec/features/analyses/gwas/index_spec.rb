require "features_helper"

RSpec.feature "Analyses index" do
  let(:user) { create(:user) }

  before { login_as(user, scope: :user) }

  scenario "can be accessed with header menu" do
    visit root_path

    find_link(text: user.full_name).click
    find_link(text: "Analyses").click

    expect(page).to have_current_path(analyses_path)
  end

  context "with no existing analyses" do
    scenario "shows informative message" do
      visit analyses_path

      expect(page).to have_css("h2.page-title", text: "My analyses")
      expect(page).to have_content("You do not have any analyses yet.")
      expect(page).to have_link("Perform new analysis")
    end
  end

  context "with existing analysees" do
    let!(:analyses) { 3.times.map { create(:analysis, :gwas, owner: user) } }

    scenario "shows list of analyses" do
      visit analyses_path

      within('ul.analyses') do
        expect(page).to have_css("li", count: 3)
        expect(page).to have_css("a", text: analyses[0].name)
        expect(page).to have_css("a", text: analyses[1].name)
        expect(page).to have_css("a", text: analyses[2].name)
      end
    end
  end
end
