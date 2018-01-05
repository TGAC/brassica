require "features_helper"

RSpec.describe "New trait view" do
  let(:admin) { create(:admin) }
  let(:trait_attrs) { attributes_for(:trait, data_provenance: "Trait ontology") }

  before do
    login_as(admin, scope: :user)
    visit new_admin_trait_path
  end

  it "allows trait creation" do
    fill_in "Name", with: trait_attrs.fetch(:name)
    fill_in "Label", with: trait_attrs.fetch(:label)
    fill_in "Description", with: trait_attrs.fetch(:description)
    fill_in "Data provenance", with: trait_attrs.fetch(:data_provenance)

    click_on "Create Trait"

    expect(page).to have_current_path(admin_traits_path)
    expect(page).to have_flash(:notice, "Trait '#{trait_attrs.fetch(:name)}' created")

    expect(Trait.last.attributes.symbolize_keys).to include(trait_attrs)
  end

  it "shows validation errors" do
    click_on "Create Trait"

    expect(page).to have_error("Please provide a trait name")
    expect(page).to have_error("Please provide a trait label")
  end
end
