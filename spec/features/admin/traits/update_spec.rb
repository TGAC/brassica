require "features_helper"

RSpec.describe "Edit trait view" do
  let(:admin) { create(:admin) }
  let(:trait_attrs) { attributes_for(:trait, data_provenance: "Trait ontology") }
  let(:trait) { Trait.create(trait_attrs) }

  before do
    login_as(admin, scope: :user)
    visit edit_admin_trait_path(trait)
  end

  it "allows trait update" do
    fill_in "Name", with: trait.name.reverse
    fill_in "Label", with: trait.label.reverse
    fill_in "Description", with: trait.description.reverse
    fill_in "Data provenance", with: trait.data_provenance.reverse

    click_on "Update Trait"

    expect(page).to have_current_path(admin_traits_path)
    expect(page).to have_flash(:notice, "Trait '#{trait.reload.name}' updated")

    expect(trait.attributes.symbolize_keys).to include(trait_attrs.transform_values(&:reverse))
  end

  it "shows validation errors" do
    fill_in "Name", with: ""
    fill_in "Label", with: ""

    click_on "Update Trait"

    expect(page).to have_error("Please provide a trait name")
    expect(page).to have_error("Please provide a trait label")
  end
end
