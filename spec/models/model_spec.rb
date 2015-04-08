require 'rails_helper'

RSpec.describe ActiveRecord::Base do
  it 'defines table and ref columns as strings only' do
    Rails.application.eager_load!
    ActiveRecord::Base.descendants.each do |model|
      if model.respond_to? 'table_columns'
        expect(model.table_columns).to all be_an(String)
      end
      if model.respond_to? 'ref_columns'
        expect(model.ref_columns).to all be_an(String)
      end
    end
  end
end
