require 'rails_helper'

RSpec.describe Relatable do
  it 'makes sure the cached counters work' do
    pp = create(:plant_population,
                linkage_maps: create_list(:linkage_map, 3, plant_population: nil))
    expect(pp.linkage_maps.count).to eq 3
    expect(pp.reload.linkage_maps_count).to eq 3
    pp.linkage_maps << create(:linkage_map, plant_population: nil)
    expect(pp.linkage_maps.count).to eq 4
    expect(pp.reload.linkage_maps_count).to eq 4
    lms = create_list(:linkage_map, 2, plant_population: nil)
    pp.linkage_maps = lms
    expect(pp.reload.linkage_maps.count).to eq 2
    expect(pp.reload.linkage_maps_count).to eq 2
  end

  it 'requires all related models to be Filterable' do
    @countable_models = relatable_models.map do |model|
      model.counter_names.map do |counter_name|
        adjust_counter_name counter_name
      end
    end.flatten.uniq
    @countable_models.each do |model|
      expect(model.classify.constantize).to include Filterable
    end
  end

  context 'for all Relatable models' do
    relatable_models.each do |klass|
      klass.count_columns.each_with_index do |count_column, i|
        relation = count_column.split(/ as /i)[0]
        relation.gsub!('_count','')
        relation = 'qtls' if relation == 'qtl'  # unfortunate special case... :(
        it "does not count inaccessible #{relation} records related to #{klass}" do
          model = adjust_model(klass.name.underscore, relation)
          related = create(adjust_counter_name(relation).singularize)
          subject = related.send(model)
          create(adjust_counter_name(relation).singularize,
                 model => subject, published: false)

          expect(subject.send(relation).count).to eq 2
          expect(subject.reload.send("#{relation}_count")).to eq 2

          td = klass.table_data.detect{ |row| row.last == subject.id }
          expect(td).not_to be_empty
          index = - klass.ref_columns.size - klass.count_columns.size + i
          expect(td[index]).to eq 1
        end

        it "counts in private owned #{relation} records for #{klass}" do
          model = adjust_model(klass.name.underscore, relation)
          related = create(adjust_counter_name(relation).singularize)
          subject = related.send(model)
          owned = create(adjust_counter_name(relation).singularize,
                         model => subject, published: false, user: create(:user))

          expect(subject.send(relation).count).to eq 2
          expect(subject.reload.send("#{relation}_count")).to eq 2

          td = klass.table_data(nil, owned.user_id).detect{ |row| row.last == subject.id }
          expect(td).not_to be_empty
          index = - klass.ref_columns.size - klass.count_columns.size + i
          expect(td[index]).to eq 2
        end

        it "requires all models related to #{klass} to allow correct filter param" do
          next if klass == Primer
          klass.counter_names.each do |model|
            permitted_params = model.classify.constantize.send(:permitted_params)
            expect(permitted_params).not_to be_empty
            expect(permitted_params.dup.extract_options![:query]).
                to include "#{klass.table_name}.id"
          end
        end
      end
    end
  end

  private

  def adjust_counter_name(counter_name)
    counter_name.end_with?('_a', '_b') ? counter_name[0..-3] : counter_name
  end

  def adjust_model(model, relation)
    model + (relation.end_with?('_a', '_b') ? relation[-2..-1] : '')
  end
end
