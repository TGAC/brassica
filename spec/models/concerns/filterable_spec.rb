require 'rails_helper'

RSpec.describe Filterable do
  describe '#params_for_filter' do
    it 'rejects aliases and related model columns' do
      all_params = [
        'normal_param',
        'alias as alias_downcase',
        'alias AS ALIAS_UPCASE',
        'related_model.param'
      ]
      class FilterableClass; include Filterable; end
      expect(FilterableClass.params_for_filter(all_params).size).to eq 1
      expect(FilterableClass.params_for_filter(all_params)[0]).to eq 'normal_param'
    end
  end

  context 'when model supports elastic search' do
    before(:all) do
      Rails.application.eager_load!
      @searchable = ActiveRecord::Base.descendants.select do |model|
        model.included_modules.include?(Elasticsearch::Model) && model != TraitDescriptor
      end
    end

    let(:search) { instance_double("Search") }
    let(:query) { { fetch: 'n' } }

    it 'includes Filterable to handle search results display' do
      @searchable.each do |searchable|
        expect(searchable.included_modules).to include Filterable
      end
    end

    it 'permits fetch in its filter params' do
      @searchable.each do |searchable|
        expect(searchable.filter(query)).not_to eq searchable.none
      end
    end

    it 'filters when fetch param is present' do
      @searchable.each do |searchable|
        expect(searchable).
          to receive(:filter).with(query).and_return(searchable.none)
        searchable.table_data(query)
      end
    end

    it 'calls Search service for results in proper model context' do
      @searchable.each do |searchable|
        expect(Search).to receive(:new).with('n').and_return(search)
        expect(search).
          to receive(searchable.table_name).and_return(searchable.search('n'))
        searchable.filter(query)
      end
    end

    it 'returns fetched records for further scoping' do
      @searchable.each do |searchable|
        s = create(searchable)
        s.send(:as_indexed_json).each do |k,v|
          if v.instance_of?(String)
            s.update_attribute(k, 'Wrapped query string')
            break
          end
        end
      end
    end
  end
end
