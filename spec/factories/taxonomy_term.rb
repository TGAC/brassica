FactoryGirl.define do
  factory :taxonomy_term do
    label { Faker::Lorem.characters(13) }
    name { Faker::Lorem.sentence }
  end
end
