class CreateTraits < ActiveRecord::Migration
  def up
    create_table :traits do |t|
      t.string :label, null: false, index: true
      t.string :name, null: false, index: { unique: true }
      t.string :description
      t.boolean :canonical, null: false, default: true
      t.string :data_provenance

      t.timestamps null: false
    end

    add_reference :trait_descriptors, :trait, index: true
    add_foreign_key :trait_descriptors, :traits, on_delete: :nullify, on_update: :cascade
    change_column_null :trait_descriptors, :descriptor_name, true
    change_column_null :trait_descriptors, :category, true

    Trait.reset_column_information
    TraitDescriptor.reset_column_information
    Rake::Task['obo:traits'].invoke

    change_column_null :trait_descriptors, :trait_id, false
  end

  def down
    remove_reference :trait_descriptors, :trait
    drop_table :traits
    change_column_null :trait_descriptors, :descriptor_name, false
    change_column_null :trait_descriptors, :category, false
  end
end
