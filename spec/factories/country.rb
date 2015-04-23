FactoryGirl.define do
  factory :country do
    sequence(:country_code) { |n| n.to_s.rjust(3, 'A') }
    country_name { Faker::Lorem.word }
  end
end
