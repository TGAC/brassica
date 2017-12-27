require "features_helper"

RSpec.describe "Traits' index" do
  let(:admin) { create(:admin) }

  before { login_as(admin, scope: :user) }

  scenario "links to new trait view" do
    visit admin_traits_path
    click_on "New trait"

    expect(page).to have_current_path(new_admin_trait_path)
  end

  context "with no existing traits" do
    scenario "shows empty page" do
      visit admin_traits_path

      expect(page).to have_css(".alert.alert-info", text: "No traits defined")
    end
  end

  context "with existing traits" do
    let!(:traits) { create_list(:trait, 2) }

    before { visit admin_traits_path }

    scenario "shows existing traits" do
      expect(page).to have_trait(traits[0])
      expect(page).to have_trait(traits[1])
    end

    scenario "allows to edit trait" do
      within_trait(traits[1]) do
        click_on "Edit"
      end

      expect(page).to have_current_path(edit_admin_trait_path(traits[1]))
    end
  end

  def within_trait(trait, &blk)
    within(:xpath, trait_xpath(trait).to_s, &blk)
  end

  def have_trait(trait)
    have_xpath(trait_xpath(trait).to_s)
  end

  def trait_xpath(trait)
    XPath.
      descendant(:table)[XPath.attr(:id) == "traits"].
      descendant(:tr)[XPath.descendant(:td).text.contains(trait.name)]
  end
end
