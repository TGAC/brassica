FactoryGirl.define do
  factory :processed_trait_dataset do
    sequence(:processed_trait_dataset_name) {|n| "#{Faker::Lorem.characters(20)}_#{n}"}
    trait_percent_heritability { Faker::Number.number(2).to_s }
    instance_eval &AnnotableFactory.annotated
    plant_population
    plant_trial
    trait_descriptor
  end
end
