FactoryGirl.define do
  factory :plant_scoring_unit do
    sequence(:scoring_unit_name) { Faker::Lorem.characters(14) }
    number_units_scored { Faker::Number.number(1).to_s + ' blocks' }
    scoring_unit_sample_size { Faker::Number.number(2).to_s + ' plants' }
    scoring_unit_frame_size { Faker::Number.number(2).to_s + ' plants in ' + Faker::Number.number(1).to_s }
    date_planted { Faker::Date.backward }
    described_by_whom { Faker::Internet.user_name }
    confirmed_by_whom { Faker::Internet.user_name }
    plant_trial
    annotable
  end
end
