class AddTraitScoresCounterToTraitDescriptors < ActiveRecord::Migration
  def up
    add_column :trait_descriptors, :trait_scores_count, :integer, null: false, default: 0

    TraitDescriptor.reset_column_information
    TraitDescriptor.pluck(:id).each do |td_id|
      TraitDescriptor.reset_counters td_id, :trait_scores
    end
  end

  def down
    remove_column :trait_descriptors, :trait_scores_count
  end
end
