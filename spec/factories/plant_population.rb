FactoryGirl.define do
  factory :plant_population do
    sequence(:name) {|n| "#{Faker::Lorem.characters(5)}_#{n}"}
    canonical_population_name { Faker::Lorem.word }
    establishing_organisation { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    male_parent_line { create(:plant_line) }
    female_parent_line { create(:plant_line) }
    published_on { Date.today-8.days }
    taxonomy_term
    population_type
    user
    annotable

    trait :with_has_many_associations do
      after(:create) do |plant_population_registry, evaluator|
        plant_population_registry.linkage_maps =
          build_list(:linkage_map, 2, plant_population_id: evaluator.id)

        plant_population_registry.population_loci =
          build_list(:population_locus, 3, plant_population_id: evaluator.id)

        plant_population_registry.plant_trials =
          build_list(:plant_trial, 2, plant_population_id: evaluator.id)

        # plant_population_registry.plant_lines = build_list(:plant_line, 4)
        plant_population_registry.plant_population_lists =
          build_list(:plant_population_list, 4, plant_population_id: evaluator.id)
      end
    end
  end
end
