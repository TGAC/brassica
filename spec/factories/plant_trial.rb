FactoryGirl.define do
  factory :plant_trial do
    sequence(:plant_trial_name) {|n| "#{Faker::Lorem.characters(5)}_#{n}"}
    sequence(:project_descriptor) {|n| "#{Faker::Lorem.word} #{n} #{Faker::Lorem.word}"}
    trial_location_site_name { Faker::Lorem.sentence }
    place_name { Faker::Lorem.sentence }
    trial_year { Faker::Date.backward.year.to_s }
    plant_trial_description { Faker::Lorem.sentence }
    contact_person { Faker::Internet.user_name }
    pubmed_id { Faker::Number.number(7) }
    confirmed_by_whom { Faker::Internet.user_name }
    published_on { Date.today-8.days }
    country
    plant_population
    layout { fixture_file_upload(Rails.root.join('app', 'assets', 'images', 'plant-trial-layout-example.jpg'), 'image/jpeg') }
    user
    annotable
  end
end
