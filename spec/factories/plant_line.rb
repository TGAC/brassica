FactoryBot.define do
  factory :plant_line do
    sequence(:plant_line_name) { |n| "#{Faker::Lorem.characters(5)}_#{n}" }
    common_name { Faker::Lorem.word }
    previous_line_name { Faker::Lorem.word }
    organisation { Faker::Company.name }
    genetic_status { Faker::Lorem.word }
    taxonomy_term
    sequence_identifier { Faker::Lorem.word }
    published_on { Date.today-8.days }
    user
    annotable

    trait :with_has_many_associations do
      after(:create) do |plant_line, evaluator|
        plant_line.fathered_descendants = build_list(:plant_population, 2, male_parent_line_id: evaluator.id)
        plant_line.mothered_descendants = build_list(:plant_population, 2, female_parent_line_id: evaluator.id)
        plant_line.plant_accessions = build_list(:plant_accession, 2, plant_line_id: evaluator.id)

        plant_line.plant_population_lists =
          build_list(:plant_population_list, 2, plant_line_id: evaluator.id)
      end
    end

    trait :not_owned_by_user do
      after(:create) do |plant_line, evaluator|
        plant_line.update_column(:user_id, nil)
      end
    end

    trait :with_variety do
      plant_variety
    end
  end
end
