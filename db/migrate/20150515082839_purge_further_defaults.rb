class PurgeFurtherDefaults < ActiveRecord::Migration
  def up
    tables = {
      linkage_groups: [:total_length],
      plant_parts: [:confirmed_by_whom, :data_provenance],
      plant_varieties: [:year_registered, :data_attribution],
      qtl: [:outer_interval_start, :inner_interval_start, :inner_interval_end, :outer_interval_end],
      trait_descriptors: [:related_characters]
    }
    purgable_values = [
      'n/a',
      'xxxx',
      'unspecified'
    ]

    tables.each do |table, columns|
      columns.each do |column|
        if column_exists?(table, column)
          purgable_values.each do |value|
            execute ("UPDATE #{table} SET #{column} = NULL WHERE #{column} = '#{value}'")
          end
        end
      end
    end
  end

  def down
  end
end
