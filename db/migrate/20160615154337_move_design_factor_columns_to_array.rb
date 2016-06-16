class MoveDesignFactorColumnsToArray < ActiveRecord::Migration
  def up
    add_column :design_factors, :design_factors, :string, array: true, null: true

    design_factors = DesignFactor.all.pluck(:id, :design_factor_1, :design_factor_2, :design_factor_3, :design_factor_4, :design_factor_5)
    design_factors.each do |id, *factor_values|
      values_string = factor_values.compact.map{ |v| "'#{v}'" }.join(',')
      query = "UPDATE design_factors SET design_factors = ARRAY[#{values_string}] WHERE id = '#{id}';"
      execute query
    end

    remove_column :design_factors, :design_factor_1
    remove_column :design_factors, :design_factor_2
    remove_column :design_factors, :design_factor_3
    remove_column :design_factors, :design_factor_4
    remove_column :design_factors, :design_factor_5

    change_column_null :design_factors, :design_factors, false
  end

  def down
    add_column :design_factors, :design_factor_1, :string, null: true
    add_column :design_factors, :design_factor_2, :string, null: true
    add_column :design_factors, :design_factor_3, :string, null: true
    add_column :design_factors, :design_factor_4, :string, null: true
    add_column :design_factors, :design_factor_5, :string, null: true

    design_factors = DesignFactor.all.pluck(:id, :design_factors)
    design_factors.each do |id, factor_array|
      values_string = factor_array.map.with_index do |value, i|
        "design_factor_#{i + 1} = '#{value}'"
      end.join(',')
      query = "UPDATE design_factors SET #{values_string} WHERE id = '#{id}';"
      execute query
    end

    remove_column :design_factors, :design_factors
  end
end
