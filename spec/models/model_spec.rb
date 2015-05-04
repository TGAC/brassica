require 'rails_helper'

RSpec::Matchers.define :display_column do |expected|
  match do |actual|
    actual.any? do |column|
      column.include?(expected)
    end
  end
end


RSpec.describe ActiveRecord::Base do
  before(:all) do
    Rails.application.eager_load!
  end

  it 'defines table, count and ref columns as strings only' do
    ActiveRecord::Base.descendants.each do |model|
      [:table_columns, :ref_columns, :count_columns].each do |columns_type|
        if model.respond_to? columns_type
          expect(model.send(columns_type)).to all be_an(String)
        end
      end
    end
  end

  it 'defined permitted query params as strings only' do
    ActiveRecord::Base.descendants.each do |model|
      if model.respond_to? :permitted_params
        expect(model.send(:permitted_params).dup.extract_options![:query]).
          to all be_an(String)
      end
    end
  end

  context 'when model supports elastic search' do
    before(:all) do
      @searchables = searchable_models
    end

    it 'ensures searchable_models helper do not make fools of us' do
      expect(@searchables).not_to be_empty
    end

    it 'makes sure all basic searchable fields are displayed in tables' do
      @searchables.each do |searchable|
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

  it 'responds with nonempty table columns when permitted for data tables' do
    allowed_models = DataTablesController.new.send(:allowed_models)
    allowed_models.each do |model|
      expect(model.classify.constantize).to respond_to(:table_columns)
      expect(model.classify.constantize.table_columns).not_to be_empty
    end
  end
end
