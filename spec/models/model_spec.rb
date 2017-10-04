require 'rails_helper'
nullify_exclusions = [PlantPopulationList, TraitScore, PlantScoringUnit, Trait]

unique_attrs = [
    [ApiKey, :token],
    [Country, :country_code],
    [LinkageGroup, :linkage_group_label],
    [LinkageMap, :linkage_map_label],
    [MarkerAssay, :marker_assay_name],
    [PlantLine, :plant_line_name],
    [PlantPart, :plant_part],
    [PlantPopulation, :name],
    [PlantTrial, :plant_trial_name],
    [PlantVariety, :plant_variety_name],
    [Primer, :primer],
    [Probe, :probe_name],
    [ProcessedTraitDataset, :processed_trait_dataset_name],
    [QtlJob, :qtl_job_name],
    [RestrictionEnzyme, :restriction_enzyme],
    [TaxonomyTerm, :name],
    [Trait, :name]
]

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

  it 'defines table, count, ref and numeric columns as strings only' do
    ActiveRecord::Base.descendants.each do |model|
      [:table_columns, :ref_columns, :count_columns, :numeric_columns].each do |columns_type|
        if model.respond_to? columns_type
          expect(model.send(columns_type)).to all be_an(String)
        end
      end
    end
  end

  it 'defines permitted query params as strings only' do
    ActiveRecord::Base.descendants.each do |model|
      if model.respond_to?(:permitted_params)
        query = model.send(:permitted_params).detect{ |x| x.is_a?(Hash) && x[:query].present? }
        if query
          hashes, others = query[:query].partition{ |q| q.is_a?(Hash) }
          expect(others).to all be_an(String)
          expect(hashes.map(&:values).flatten).to all match_array []
        end
      end
    end
  end

  it 'nullifies all belongs_to relations on destroy' do
    Api.writable_models.each do |model_klass|
      next if nullify_exclusions.include? model_klass # Some classes are not expected to follow this rule.
      instance = create(model_klass)
      (all_belongs_to(model_klass) - [:user, :trait]).each do |belongs_to|
        unless instance.send("#{belongs_to}_id").nil?
          instance.send(belongs_to).destroy
          expect(instance.reload.send("#{belongs_to}_id")).to be_nil
        end
      end
    end
  end

  it 'prevents assignment of invalid foreign keys' do
    Api.writable_models.each do |model_klass|
      # Exception created due to the fact that the custom validator present in PA interferes with this test
      unless model_klass == PlantAccession
        instance = create(model_klass)
        all_belongs_to(model_klass).each do |belongs_to|
          expect{ instance.update("#{belongs_to}_id" => 555666) }.
            to raise_error ActiveRecord::InvalidForeignKey
        end
      end
    end
  end

  context 'when model supports elastic search' do
    before(:all) do
      @searchables = searchable_models
    end

    it 'ensures searchable_models helper does not make fools of us' do
      expect(@searchables).not_to be_empty
    end

    it 'makes sure all basic searchable fields are displayed in tables' do
      @searchables.each do |searchable|
        next if searchable == Qtl
        instance = create(searchable)
        instance.as_indexed_json.each do |k, v|
          next if k == 'id' || k == 'trait_name'  # twice the same, doesn't hurt
          if v.instance_of? Hash
            v.each do |column, value|
              if value.instance_of? Hash
                value.each do |deep_column, _|
                  expect(searchable.table_columns).
                    to display_column(column.pluralize + '.' + deep_column)
                end
              else
                expect(searchable.table_columns).
                  to display_column(instance.send(k).class.table_name + '.' + column)
              end
            end
          else
            expect(searchable.table_columns).
              to display_column(k).or display_column(searchable.table_name + '.' + k)
          end
        end
      end
    end

    it 'is also Filterable to provide search result fetching' do
      @searchables.each do |searchable|
        next if searchable == TraitDescriptor  # it implements fetching without importing Filterable
        expect(searchable.ancestors.include?(Filterable)).to be_truthy
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

  it 'does not use count aggregations in table columns' do
    allowed_models = DataTablesController.new.send(:allowed_models)
    allowed_models.each do |model|
      model.classify.constantize.table_columns.each do |c|
        expect(c).not_to include('(')
      end
    end
  end

  context 'publishable records' do
    let(:omitted_tables) {
      [
        'analyses',
        'analysis_data_files',
        'api_keys',
        'countries',
        'delayed_jobs',
        'schema_migrations',
        'submission_uploads',
        'submissions',
        'users',
        'genotype_matrices',
        'pop_type_lookup',
        'processed_trait_datasets',
        'marker_sequence_assignments',
        'plant_variety_country_registered',
        'plant_variety_country_of_origin',
        'taxonomy_terms',
        'trait_grades',
        'plant_parts',
        'restriction_enzymes',
        'traits'
      ]
    }

    it 'contains published column in all tables except those belonging to a specified set' do
      tables = ActiveRecord::Base.connection.tables
      tables.reject!{|t| omitted_tables.include? t}

      tables.each do |t|
        expect(ActiveRecord::Base.connection.column_exists?(t, :published)).to be_truthy
      end
    end

    it 'does not allow ownerless unpublished records' do
      ActiveRecord::Base.send(:subclasses).
        reject { |model| model.table_name.in?(omitted_tables) }.
        select { |model| (model.column_names & ['user_id', 'published']).length == 2 }.
        each do |model|
          record = model.new(user: nil, published: false)
          expect(record.valid?).to be_falsy
          expect(record.errors[:published]).to eq ['An ownerless record must have its published flag set to true.']
        end
    end

    it 'allows query by user_id' do
      Api.writable_models.each do |model|
        query = model.send(:permitted_params).detect{ |x| x.is_a?(Hash) && x[:query].present? }[:query]
        expect(query).to include 'user_id'
      end
    end
  end

  context 'when having includes in json_options' do
    it 'never includes publishable models' do
      ActiveRecord::Base.send(:subclasses).each do |model|
        if model.respond_to?(:json_options) && model.json_options[:include].present?
          model.json_options[:include].each do |included_relation|
            related_model = model.reflect_on_association(included_relation).klass
            expect(related_model.respond_to?(:published)).to be_falsey
          end
        end
      end
    end
  end
end

unique_attrs.each do |class_name, column_name|
  RSpec.describe class_name, type: :model do
    it { should have_db_index(column_name).unique }
  end
end
