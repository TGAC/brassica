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
    confirmed_by_whom { Faker::Internet.user_name }
    published_on { Date.today-8.days }
    user
    annotable
  end
end
