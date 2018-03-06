require "rails_helper"

RSpec.describe "Data files management" do
  context "with no user signed in" do
    let!(:data_file) { create(:analysis_data_file) }

    describe "GET /analyses/data_files/:id" do
      it "redirects to home page" do
        get analyses_data_file_path(data_file)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  context "with user signed in" do
    let(:user) { create :user }
    let!(:owned_data_file) { create(:analysis_data_file, :gwasser_results, owner: user) }
    let!(:other_data_file) { create(:analysis_data_file) }

    before { login_as(user) }

    describe "GET /analyses/data_files/:id" do
      it "allows to download own file" do
        get analyses_data_file_path(owned_data_file)
        expect(response).to be_success
        expect(response.content_type.to_s).to eq("text/csv")
        expect(response.body).to start_with("ID,fvalues,minlogp")
      end

      it "does not allow to download other user's file" do
        expect { get analyses_data_file_path(other_data_file) }.
          to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
