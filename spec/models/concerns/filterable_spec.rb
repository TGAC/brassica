require 'rails_helper'

RSpec.describe Filterable do
  context 'when model supports elastic search' do
    before(:all) do
      Rails.application.eager_load!
      @searchable = ActiveRecord::Base.descendants.select do |model|
        model.included_modules.include? Elasticsearch::Model
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
        # expect(searchable.filter(fetch: 'query').to_a).to eq [s]
        pending 'Uncomment the above expectation if ES testing is possible'
        fail
      end
    end
  end
end
