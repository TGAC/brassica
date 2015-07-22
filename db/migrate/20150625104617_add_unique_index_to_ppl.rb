class AddUniqueIndexToPpl < ActiveRecord::Migration
  def change
    add_index(:plant_population_lists, [:plant_line_id, :plant_population_id], unique: true, name: 'unique_ppl_idx')
  end
end
