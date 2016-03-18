FactoryGirl.define do
  factory :population_type do
    population_type { Faker::Lorem.word }
    population_class { Faker::Lorem.word }
    published_on { Date.today-8.days }
  end
end
