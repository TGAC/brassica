class CleanUpTraitScores < ActiveRecord::Migration
  def up
    remove_column :trait_scores, :replicate_score_reading
    remove_column :trait_scores, :score_spread
  end

  def down
    add_column :trait_scores, :replicate_score_reading, :text, default: '1'
    add_column :trait_scores, :score_spread, :text
  end
end