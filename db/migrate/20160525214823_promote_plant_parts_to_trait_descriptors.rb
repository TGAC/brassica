class PromotePlantPartsToTraitDescriptors < ActiveRecord::Migration
  def change
    add_reference :trait_descriptors, :plant_part, index: true
    add_foreign_key :trait_descriptors, :plant_parts, on_delete: :nullify, on_update: :cascade

    Rake::Task['curate:promote_plant_parts_to_traits'].invoke

    remove_reference :plant_scoring_units, :plant_part
  end
end
