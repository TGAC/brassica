class AddTimestampsToDbColumns < ActiveRecord::Migration
  @@dbtables_no_timestamps = [
    :design_factors,
    :genotype_matrices,
    :marker_sequence_assignments,
    :plant_parts,
    :processed_trait_datasets,
    :restriction_enzymes,
    :trait_grades
  ]

  def up
    @@dbtables_no_timestamps.each do |t|
      add_timestamps t
      execute("UPDATE #{t} SET created_at = '#{Date.today-8.days}'")
      execute("UPDATE #{t} SET updated_at = '#{Date.today-8.days}'")
    end
  end

  def down
    @@dbtables_no_timestamps.each do |t|
      remove_timestamps t
    end
  end
end
