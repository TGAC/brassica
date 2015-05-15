FactoryGirl.define do
  factory :plant_line do
    sequence(:plant_line_name) { |n| "#{Faker::Lorem.characters(5)}_#{n}" }
    common_name { Faker::Lorem.word }
    previous_line_name { Faker::Lorem.word }
    organisation { Faker::Company.name }
    genetic_status { Faker::Lorem.word }
    taxonomy_term
    user
    annotable

    trait :with_has_many_associations do
      after(:create) do |plant_line_registry, evaluator|
        plant_line_registry.fathered_descendants = build_list(:plant_population, 2, male_parent_line_id: evaluator.id)
        plant_line_registry.mothered_descendants = build_list(:plant_population, 2, female_parent_line_id: evaluator.id)
        plant_line_registry.plant_accessions = build_list(:plant_accession, 2, plant_line_id: evaluator.id)
        plant_line_registry.plant_populations = build_list(:plant_population, 2)
      end
    end
  end
end
