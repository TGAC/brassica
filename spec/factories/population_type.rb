FactoryGirl.define do
  factory :population_type do
    population_type { Faker::Lorem.word }
    population_class { Faker::Lorem.word }
  end
end
