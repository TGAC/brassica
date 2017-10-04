class AddOriginToAnalysisDataFiles < ActiveRecord::Migration
  def change
    add_column :analysis_data_files, :origin, :integer, null: false, default: 0
  end
end
