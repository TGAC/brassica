FactoryGirl.define do
  factory :population_type_lookup do
    population_type { Faker::Lorem.word }
  end
end
