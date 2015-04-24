require 'rails_helper'

RSpec.describe ActiveRecord::Base do
  before(:all) do
    Rails.application.eager_load!
  end

  it 'defines table and ref columns as strings only' do
    ActiveRecord::Base.descendants.each do |model|
      if model.respond_to? 'table_columns'
        expect(model.table_columns).to all be_an(String)
      end
      if model.respond_to? 'ref_columns'
        expect(model.ref_columns).to all be_an(String)
      end
    end
  end

  it 'responds with nonempty table columns when permitted for data tables' do
    allowed_models = DataTablesController.new.send(:allowed_models)
    allowed_models.each do |model|
      expect(model.classify.constantize).to respond_to(:table_columns)
      expect(model.classify.constantize.table_columns).not_to be_empty
    end
  end
end
