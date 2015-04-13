FactoryGirl.define do
  factory :plant_trial do
    sequence(:plant_trial_name) {|n| "#{Faker::Lorem.characters(5)}_#{n}"}
    project_descriptor { Faker::Lorem.word }
    trial_location_site_name { Faker::Lorem.sentence }
    place_name { Faker::Lorem.sentence }
    trial_year { Faker::Date.backward.year.to_s }
    plant_trial_description { Faker::Lorem.sentence }
    contact_person { Faker::Internet.user_name }
    confirmed_by_whom { Faker::Internet.user_name }
    country
    plant_population
    instance_eval &AnnotableFactory.annotated
  end
end
