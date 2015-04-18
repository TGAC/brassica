FactoryGirl.define do
  factory :plant_variety do
    sequence(:plant_variety_name) {|n| "#{Faker::Lorem.characters(5)}_#{n}"}
    crop_type { Faker::Lorem.word }
    year_registered { "2015" }
    breeders_variety_code { Faker::Lorem.word }
    owner { Faker::Company.name }
    female_parent { Faker::Lorem.word }
    male_parent { Faker::Lorem.word }
    annotable_no_owner
  end
end
