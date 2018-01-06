require 'rails_helper'

RSpec.describe SearchesController do
  describe "GET :counts" do
    let(:search) { instance_double("Search") }

    it "returns counts of found records" do
      expect(Search).to receive(:new).with("foo").and_return(search)
      expect(search).to receive(:counts)

      get :counts, params: { search: "foo" }

      expect(response).to be_success
      expect(response).to render_template("searches/counts")
    end
  end
end
