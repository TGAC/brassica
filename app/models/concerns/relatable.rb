# Single Concern for all models that relate to others
# in DataTables through 'count' columns.
# For each this_model.has_many :m (with model M) you'd like to relate to, you should:
#  - add ms_count column to this_models table (in migrations)
#  - add "counter_cache: true" to M.belongs_to this_model declaration
#  - add 'ms_count' string to self.count_columns below
#  - include Filterable in M
#  - add 'this_models.id' to M.permitted_params for :query hash
module Relatable extend ActiveSupport::Concern
  included do
    # Provides table_names for related, counted models
    def self.counter_names
      count_columns.map do |column|
        get_related_model(column)
      end
    end

    def self.count_columns
      []
    end

    private

    def self.get_related_model(counter_name)
      counter_name.match(/\(([^\)]+)\)/) do |match|
        counter_name = match[0][1..-2]  # remove aggregation function
      end
      counter_name = counter_name.split(/ as /i)[-1]  # honor aliasing
      counter_name.gsub!('_count','')   # support cached count columns as well

      if counter_name.include? '.'
        counter_name.split('.')[-1]
      else
        counter_name
      end
    end
  end
end
