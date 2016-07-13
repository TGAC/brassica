class LoadAdditionalTraitDescriptors < ActiveRecord::Migration
  def up
    Trait.reset_column_information
    TraitDescriptor.reset_column_information
    Rake::Task['traits:load_new_trait_descriptors'].invoke
  end

  def down
    TraitDescriptor.where(descriptor_label: 'BIP/EI').destroy_all
    Trait.where(label: 'BIP/EI').destroy_all
  end
end
