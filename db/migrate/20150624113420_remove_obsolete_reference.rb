class RemoveObsoleteReference < ActiveRecord::Migration
  def up
    if column_exists?(:trait_scores, :scoring_occasion_id)
      remove_column :trait_scores, :scoring_occasion_id
    end
  end

  def down
    # Do nothing
  end
end