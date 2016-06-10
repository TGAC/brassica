class EditFactors < ActiveRecord::Migration
  require File.expand_path('lib/migration_helper')
  include MigrationHelper

  def up
    if column_exists?(:plant_trials, :statistical_factors)
      pts = execute("SELECT statistical_factors FROM plant_trials WHERE statistical_factors LIKE '%replicate%'")
      puts "Found #{pts.count} PlantTrial records with the word 'replicate' in the statistical_factors field."

      pts.each do |pt|
        factors = escape(pt['statistical_factors'])
        execute "
          UPDATE plant_trials
          SET statistical_factors = E'#{factors.gsub('replicate','rep')}'
          WHERE statistical_factors = E'#{factors}'
        "
      end
    end

    if column_exists?(:plant_trials, :design_factors)
      pts = execute("SELECT design_factors FROM plant_trials WHERE design_factors LIKE '%replicate%'")
      puts "Found #{pts.count} PlantTrial records with the word 'replicate' in the design_factors field."

      pts.each do |pt|
        factors = escape(pt['design_factors'])
        execute "
          UPDATE plant_trials
          SET design_factors = E'#{factors.gsub('replicate','rep')}'
          WHERE design_factors = E'#{factors}'
        "
      end
    end
  end

  def down
  end
end
