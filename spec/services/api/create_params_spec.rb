require 'rails_helper'

RSpec.describe Api::CreateParams do
  describe "#permissions" do
    it "allows scalar model attributes" do
      pl_permissions = Api::CreateParams.new(Api::Model.new('plant_line'), {}).permissions
      expect(pl_permissions).to match_array %w(plant_line_name common_name
        organisation sequence_identifier genetic_status previous_line_name
        comments named_by_whom data_provenance data_owned_by confirmed_by_whom
        taxonomy_term_id plant_variety_id plant_variety_name published)
    end

    it "allows arrays of ids for HABTM associations" do
      pv_permissions = Api::CreateParams.new(Api::Model.new('plant_variety'), {}).permissions
      expect(pv_permissions).to include(
        'countries_registered_ids' => [],
        'countries_of_origin_ids' => []
      )

      pl_permissions = Api::CreateParams.new(Api::Model.new('plant_line'), {}).permissions
      expect(pl_permissions.count { |p| p.is_a?(Hash) }).to eq 0
    end

    it "allows arrays of values for array model attributes" do
      df_permissions = Api::CreateParams.new(Api::Model.new('design_factor'), {}).permissions
      expect(df_permissions).to include('design_factors' => [])
    end

    it "does not list columns of array data type as scalars" do
      df_permissions = Api::CreateParams.new(Api::Model.new('design_factor'), {}).permissions
      expect(df_permissions).not_to include('design_factors')
    end

    describe "#permitted_params" do
      it "filters out blacklisted attributes" do
        pl_attrs = { 'plant_line' => {
          'id' => 9,
          'date_entered' => Date.today.to_s,
          'plant_line_name' => 'Foo'
        } }
        request_params = ActionController::Parameters.new(pl_attrs)
        permitted_params = Api::CreateParams.new(Api::Model.new('plant_line'), request_params).permitted_params

        expect(permitted_params).to eq('plant_line_name' => 'Foo')
      end
    end

    describe "#misnamed_attrs" do
      it "returns unknown / misnamed attributes" do
        pl_attrs = { 'plant_line' => {
          'id' => 9,
          'burumburum' => 123,
          'kwak' => false
        } }
        request_params = ActionController::Parameters.new(pl_attrs)
        misnamed_attrs = Api::CreateParams.new(Api::Model.new('plant_line'), request_params).misnamed_attrs

        expect(misnamed_attrs).to match_array ['kwak', 'burumburum']
      end
    end
  end
end
