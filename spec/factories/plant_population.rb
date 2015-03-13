FactoryGirl.define do
  factory :plant_population do
    # plant_population_id { Faker::Lorem.word }
    # plant_population_id {"ppid_#{rand(1000).to_s}" }
    species { Faker::Lorem.word }
    canonical_population_name { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    data_provenance { Faker::Lorem.sentence }
  end
end
