# Single Concern for all models that relate to others
# in DataTables through 'count' columns.
# For each this_model.has_many :m (with model M) you'd like to relate to, you should:
#  - add ms_count column to this_models table (in migrations)
#  - add "counter_cache: true" to M.belongs_to this_model declaration
#  - add 'ms_count' string to self.count_columns below
#  - include Filterable in M
#  - add 'this_models.id' to M.permitted_params for :query hash
# If the model redefines its own table_data, you need to add the following there:
#  - query = join_counters(query, uid)
#  - use privacy_adjusted_count_columns in pluck (NOT simply count_columns)
module Relatable extend ActiveSupport::Concern
  included do
    # Provides table_names for related, counted models
    def self.counter_names
      count_columns.map do |column|
        get_related_model(column)
      end
    end

    def self.privacy_adjusted_count_columns
      count_columns.map do |column|
        counter_column = column.split(/ as /i)[0]
        as_column = column.split(/ as /i)[-1]
        "(#{table_name}.#{counter_column} - coalesce(#{get_related_model(counter_column)}.hidden, 0)) AS #{as_column}"
      end
    end

    # Left outer joins all countable relations in order to deduct the number
    # of 'hidden' records (i.e. related records that are not visible to the
    # uid user).
    def self.join_counters(query, uid = nil)
      count_columns.each do |count_column|
        relation = get_related_model(count_column.split(/ as /i)[0])
        related_klass = adjust_related_name(relation).classify.constantize
        fkey = reverse_relation_key(relation)
        self_table = self.table_name
        subquery = related_klass.hidden(uid).
                                 group(fkey).
                                 select{ [fkey, count(id).as(hidden)] }
        query = query.joins{ subquery.
                             as(relation).
                             on{ __send__(relation).send(fkey).eq(__send__(self_table).send('id')) }.
                             outer }
      end
      query
    end

    def self.count_columns
      []
    end

    private

    def self.get_related_model(counter_name)
      counter_name = counter_name.split(/ as /i)[-1]  # honor aliasing
      counter_name.gsub!('_count','')   # support cached count columns as well
      counter_name.gsub!('qtls','qtl')  # unfortunate special case... :(
      counter_name
    end

    def self.adjust_related_name(related_name)
      related_name.end_with?('_a', '_b') ? related_name[0..-3] : related_name
    end

    def self.reverse_relation_key(forward_relation)
      reverse_relation = self.name.underscore
      reverse_relation += forward_relation[-2..-1] if forward_relation.end_with?('_a', '_b')
      "#{reverse_relation}_id"
    end
  end
end
