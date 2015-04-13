FactoryGirl.define do
  factory :plant_population do
    name { Faker::Lorem.word }
    canonical_population_name { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    taxonomy_term
    population_type
    instance_eval &AnnotableFactory.annotated
  end
end
