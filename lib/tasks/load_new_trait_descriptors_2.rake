namespace :traits do
  desc 'Loads Traits and Trait Descriptors provided by Annemarie by email 01.09.2016'
  task load_new_trait_descriptors_2: :environment do
    CSV.foreach('db/data/new_trait_descriptors_2.csv') do |row|
      next if row[0].include? 'trait_descriptors'  # the header

      trait = Trait.find_or_initialize_by(name: row[5])
      trait.name = row[4]
      trait.label = 'BIP/EI'
      trait.description = row[3]
      trait.data_provenance = row[2]
      trait.canonical = false

      trait.save!

      plant_part = row[1].present? ? PlantPart.find_by(plant_part: row[1]) : nil

      TraitDescriptor.create!(
        category: row[0],
        stage_scored: row[1],
        scoring_method: row[6],
        units_of_measurements: row[7],
        trait: trait,
        descriptor_label: 'BIP/EI',
        data_provenance: 'BIP/EI 09.2016',
        plant_part: plant_part
      )
    end
  end
end
