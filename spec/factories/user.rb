FactoryGirl.define do
  factory :user do
    login { Faker::Lorem.characters(10) }
    email { Faker::Internet.email }
    full_name { Faker::Name.name }
  end
end
