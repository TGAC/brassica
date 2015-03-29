FactoryGirl.define do
  factory :plant_population do
    canonical_population_name { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    data_provenance { Faker::Lorem.sentence }
    taxonomy_term
  end
end
