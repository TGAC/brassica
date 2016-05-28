namespace :curate do
  desc 'Moves relation with PlantParts from PSU level to TD level'
  task promote_plant_parts_to_traits: :environment do
    TraitDescriptor.all.each do |trait_descriptor|
      psus = trait_descriptor.trait_scores.pluck(:plant_scoring_unit_id)
      plant_part_id = PlantScoringUnit.where(id: psus).pluck(:plant_part_id).uniq
      raise "Non-deterministic plant part mapping for TD #{trait_descriptor.descriptor_name}" if plant_part_id.size > 1
      if plant_part_id.size == 1 && !plant_part_id[0].nil?
        trait_descriptor.update_column(:plant_part_id, plant_part_id[0].to_i)
      end
    end
  end
end
