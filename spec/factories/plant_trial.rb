FactoryGirl.define do
  factory :plant_trial do
    sequence(:plant_trial_name) {|n| "#{Faker::Lorem.characters(5)}_#{n}"}
    project_descriptor { Faker::Lorem.word }
    date_entered { Faker::Date.backward }
    comments { Faker::Lorem.sentence }
    trial_location_site_name { Faker::Lorem.sentence }
    place_name { Faker::Lorem.sentence }
    trial_year { Faker::Date.backward.year.to_s }
    plant_trial_description { Faker::Lorem.sentence }
    data_provenance { Faker::Lorem.sentence }
    entered_by_whom { Faker::Internet.user_name }
    contact_person { Faker::Internet.user_name }
    confirmed_by_whom { Faker::Internet.user_name }
    data_owned_by { Faker::Company.name }
    country
    plant_population
  end
end
