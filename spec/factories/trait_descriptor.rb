FactoryGirl.define do
  factory :trait_descriptor do
    sequence(:descriptor_label) { Faker::Lorem.characters(14) }
    category { Faker::Lorem.word + ' ' + Faker::Lorem.word }
    descriptor_name { Faker::Lorem.sentence }
    units_of_measurements { Faker::Lorem.sentence + ' (%)' }
    where_to_score { Faker::Lorem.sentence }
    scoring_method { Faker::Lorem.sentence }
    when_to_score { Faker::Lorem.sentence }
    stage_scored { Faker::Lorem.sentence }
    precautions { Faker::Lorem.sentence }
    materials { Faker::Lorem.sentence }
    controls { Faker::Lorem.sentence }
    calibrated_against { Faker::Lorem.sentence }
    instrumentation_required { Faker::Lorem.sentence }
    likely_ambiguities { Faker::Lorem.sentence }
    contact_person { Faker::Internet.user_name }
    date_method_agreed { Faker::Date.backward }
    comments { Faker::Lorem.sentence }
    date_entered { Faker::Date.backward }
    data_provenance { Faker::Lorem.sentence }
    entered_by_whom { Faker::Internet.user_name }
    confirmed_by_whom { Faker::Internet.user_name }
    data_owned_by { Faker::Company.name }
  end
end
