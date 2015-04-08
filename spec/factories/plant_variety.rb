FactoryGirl.define do
  factory :plant_variety do
    sequence(:plant_variety_name) {|n| "#{Faker::Lorem.characters(5)}_#{n}"}
    crop_type { Faker::Lorem.word }
    comments { Faker::Lorem.sentence }
    entered_by_whom { Faker::Internet.user_name }
    date_entered { Date.today }
    year_registered { "2015" }
    breeders_variety_code { Faker::Lorem.word }
    owner { Faker::Company.name }
    female_parent { Faker::Lorem.word }
    male_parent { Faker::Lorem.word }
  end
end
