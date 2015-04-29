FactoryGirl.define do
  factory :plant_population do
    name { Faker::Lorem.word }
    canonical_population_name { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    male_parent_line { create(:plant_line) }
    female_parent_line { create(:plant_line) }
    taxonomy_term
    population_type
    annotable
  end
end
