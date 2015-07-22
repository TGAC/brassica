require 'rails_helper'

RSpec.describe Annotable do
  it 'makes sure all tables are instantiable as models' do
    annotable_tables.each{ |t| t.singularize.camelize.constantize }
  end

  it 'provides rudimentary ref_columns set for all models' do
    annotable_tables.each do |table|
      klass = table.singularize.camelize.constantize
      expect{ klass.ref_columns }.not_to raise_error
      expect(klass.ref_columns.last).to eq "#{table}.id"
    end
  end

  it 'makes sure all annotable models include this concern' do
    no_factory = []
    not_made_annotable = []
    annotable_tables.each do |table|
      begin
        instance = create(table.singularize)
        test_hash = {
          'comments' => instance.comments,
          'entered_by_whom' => instance.entered_by_whom,
          'data_provenance' => instance.data_provenance
        }.merge(
          instance.has_attribute?('data_owned_by') ? { 'data_owned_by' => instance.data_owned_by } : {}
        ).merge(
          instance.has_attribute?('date_entered') ? { 'date_entered' => instance.date_entered } : {}
        ).merge(
          instance.has_attribute?('pubmed_id') ? { 'pubmed_id' => instance.pubmed_id } : {}
        ).merge(
          instance.respond_to?('published?') ? { 'published?' => instance.published? } : {}
        )
        expect(instance.annotations_as_json).to eq test_hash
        expect(test_hash.values.map(&:nil?)).to all be_falsey
      rescue ArgumentError => e
        no_factory << table.singularize
      rescue NoMethodError => e
        if e.message.include? 'annotations_as_json'
          not_made_annotable << table.singularize
        else
          fail(e.message)
        end
      end
    end

    if no_factory.present?
      pending "Factories for #{no_factory} not registered yet."
    end

    if not_made_annotable.present?
      pending "#{not_made_annotable} should include Annotable"
    end

    fail if no_factory.present? || not_made_annotable.present?
  end

  it 'makes sure all pubmed models are Annotable' do
    ActiveRecord::Base.descendants.each do |model|
      if model.column_names.include? 'pubmed_id'
        expect(annotable_tables).to include model.table_name
      end
    end
  end

  it 'makes sure all API-writable models return published?' do
    Api.writable_models.each do |model_klass|
      next unless annotable_tables.include?(model_klass.table_name)
      instance = create(model_klass)
      expect(instance.annotations_as_json.keys).to include 'published?'
    end
  end

  context 'when model is Pluckable as well' do
    it 'plucks at least the id column' do
      annotable_tables.each do |table|
        klass = table.singularize.camelize.constantize
        if klass.ancestors.include? Pluckable
          expect(klass.ref_columns.last).to eq "#{table}.id"
          klass.destroy_all
          instances = create_list(table.singularize, 3)
          expect(klass.pluck_columns.map(&:last)).
            to match_array instances.map(&:id)
        end
      end
    end
  end
end
