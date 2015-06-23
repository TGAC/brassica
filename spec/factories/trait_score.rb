FactoryGirl.define do
  factory :trait_score do
    score_value { Faker::Number.number(10).to_s }
    value_type { Faker::Lorem.sentence }
    scoring_date { rand(1..100).days.ago }
    confirmed_by_whom { Faker::Internet.user_name }
    plant_scoring_unit
    user
    trait_descriptor
    annotable
  end
end
