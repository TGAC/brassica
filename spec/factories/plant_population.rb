FactoryGirl.define do
  factory :plant_population do
    species { Faker::Lorem.word }
    canonical_population_name { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    data_provenance { Faker::Lorem.sentence }
  end
end
