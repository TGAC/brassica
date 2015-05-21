FactoryGirl.define do
  factory :plant_variety do
    sequence(:plant_variety_name) {|n| "#{Faker::Lorem.characters(5)}_#{n}"}
    crop_type { Faker::Lorem.word }
    year_registered { "2015" }
    breeders_variety_code { Faker::Lorem.word }
    owner { Faker::Company.name }
    female_parent { Faker::Lorem.word }
    male_parent { Faker::Lorem.word }
    quoted_parentage{ Faker::Lorem.sentence }
    annotable_no_owner

    trait :with_has_many_associations do
      after(:create) do |plant_variety_registry, evaluator|
        plant_variety_registry.plant_lines = build_list(:plant_line, 2, plant_variety_id: evaluator.id)
        plant_variety_registry.countries_of_origin = build_list(:country, 3)
        plant_variety_registry.countries_registered = build_list(:country, 2)
      end
    end
  end
end
