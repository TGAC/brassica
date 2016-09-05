class LoadAdditionalTraitDescriptors2 < ActiveRecord::Migration
  def up
    Rake::Task['traits:load_new_trait_descriptors_2'].invoke
  end

  def down
    TraitDescriptor.where(data_provenance: 'BIP/EI 09.2016').each do |td|
      td.destroy
      td.trait.destroy
    end
  end
end
