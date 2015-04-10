FactoryGirl.define do
  factory :taxonomy_term do
    label { Faker::Lorem.characters(13) }
    name { 'Brassica ' + Faker::Lorem.characters(10) }
  end
end
