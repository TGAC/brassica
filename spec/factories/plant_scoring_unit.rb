FactoryGirl.define do
  factory :plant_scoring_unit do
    sequence(:scoring_unit_name) { Faker::Lorem.characters(14) }
    number_units_scored { Faker::Number.number(1).to_s + ' blocks' }
    scoring_unit_sample_size { Faker::Number.number(2).to_s + ' plants' }
    scoring_unit_frame_size { Faker::Number.number(2).to_s + ' plants in ' + Faker::Number.number(1).to_s }
    date_planted { Faker::Date.backward }
    described_by_whom { Faker::Internet.user_name }
    comments { Faker::Lorem.sentence }
    date_entered { Faker::Date.backward }
    data_provenance { Faker::Lorem.sentence }
    entered_by_whom { Faker::Internet.user_name }
    confirmed_by_whom { Faker::Internet.user_name }
    data_owned_by { Faker::Company.name }
    plant_trial
  end
end
