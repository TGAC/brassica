class PromotePlantPartsToTraitDescriptors < ActiveRecord::Migration
  def up
    add_reference :trait_descriptors, :plant_part, index: true
    add_foreign_key :trait_descriptors, :plant_parts, on_delete: :nullify, on_update: :cascade

    Rake::Task['curate:promote_plant_parts_to_traits'].invoke

    remove_reference :plant_scoring_units, :plant_part
  end

  def down
    add_reference :plant_scoring_units, :plant_part, index: true
    add_foreign_key :plant_scoring_units, :plant_parts, on_delete: :nullify, on_update: :cascade

    Rake::Task['curate:demote_plant_parts_to_psus'].invoke

    remove_reference :trait_descriptors, :plant_part
  end
end
