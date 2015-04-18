FactoryGirl.define do
  factory :trait_score do
    sequence(:scoring_occasion_name) { Faker::Lorem.characters(10) }
    score_value { Faker::Number.number(10).to_s }
    value_type { Faker::Lorem.sentence }
    confirmed_by_whom { Faker::Internet.user_name }
    plant_scoring_unit
    instance_eval &AnnotableFactory.annotated
    trait_descriptor
  end
end
