namespace :traits do
  desc 'Loads Traits and Trait Descriptors provided by Annemarie in issue #574'
  task load_new_trait_descriptors: :environment do
    CSV.foreach('db/data/new_trait_descriptors.csv') do |row|
      next if row[0] == 'trait_descriptors'  # the header

      trait = Trait.create!(
                name: row[3],
                label: 'BIP/EI',
                description: row[2],
                data_provenance: row[4],
                canonical: false
              )

      TraitDescriptor.create!(
        category: row[0],
        stage_scored: row[1],
        scoring_method: row[5],
        units_of_measurements: row[6],
        trait: trait,
        descriptor_label: 'BIP/EI',
        data_provenance: 'BIP/EI',
        plant_part: PlantPart.find_by(plant_part: row[7])
      )
    end
  end
end
