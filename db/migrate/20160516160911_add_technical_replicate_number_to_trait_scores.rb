class AddTechnicalReplicateNumberToTraitScores < ActiveRecord::Migration
  def change
    add_column :trait_scores, :technical_replicate_number, :integer, default: 1, null: false
  end
end
