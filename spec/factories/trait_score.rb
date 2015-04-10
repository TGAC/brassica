FactoryGirl.define do
  factory :trait_score do
    sequence(:scoring_occasion_name) { Faker::Lorem.characters(10) }
    replicate_score_reading { '1' }
    score_value { Faker::Number.number(10).to_s }
    score_spread { '' }
    value_type { Faker::Lorem.sentence }
    comments { Faker::Lorem.sentence }
    date_entered { Faker::Date.backward }
    data_provenance { Faker::Lorem.sentence }
    entered_by_whom { Faker::Internet.user_name }
    confirmed_by_whom { Faker::Internet.user_name }
    data_owned_by { Faker::Company.name }
    plant_scoring_unit
  end
end
