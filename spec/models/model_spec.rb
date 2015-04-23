require 'rails_helper'

RSpec::Matchers.define :display_column do |expected|
  match do |actual|
    actual.any? do |column|
      column.include?(expected)
    end
  end
end

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

  context 'when model supports elastic search' do
    before(:all) do
      @searchable = searchable_models
    end

    it 'makes sure all basic searchable fields are displayed in tables' do
      @searchable.each do |searchable|
        instance = create(searchable)
        instance.send(:as_indexed_json).each do |k,v|
          next if k == 'id'
          if v.instance_of? Hash
            v.each do |column,_|
              expect(searchable.table_columns).
                to display_column(instance.send(k).class.table_name + '.' + column)
            end
          else
            expect(searchable.table_columns).
              to display_column(k).or display_column(searchable.table_name + '.' + k)
          end
        end
      end
    end
  end
end
