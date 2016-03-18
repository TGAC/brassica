FactoryGirl.define do
  factory :taxonomy_term do
    name { 'Brassica ' + Faker::Lorem.characters(10) }
    label { Faker::Lorem.characters(13) }
    published_on { Date.today-8.days }
  end
end
