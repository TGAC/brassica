class RemoveNullConstraintsFromDesignFactors < ActiveRecord::Migration
  def up
    change_column_null :design_factors, :institute_id, true
    change_column_null :design_factors, :trial_location_name, true
    change_column_null :design_factors, :design_factor_name, true
  end

  def down
    change_column_null :design_factors, :institute_id, false
    change_column_null :design_factors, :trial_location_name, false
    change_column_null :design_factors, :design_factor_name, false
  end
end
