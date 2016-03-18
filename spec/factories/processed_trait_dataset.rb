FactoryGirl.define do
  factory :processed_trait_dataset do
    sequence(:processed_trait_dataset_name) {|n| "#{Faker::Lorem.characters(20)}_#{n}"}
    trait_percent_heritability { Faker::Number.number(2).to_s }
    published_on { Date.today-8.days }
    annotable
    plant_trial
    trait_descriptor
  end
end
