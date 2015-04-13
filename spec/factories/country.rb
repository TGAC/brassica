FactoryGirl.define do
  factory :country do
    country_code { Faker::Lorem.characters(3).upcase }
    country_name { Faker::Lorem.word }
  end
end
