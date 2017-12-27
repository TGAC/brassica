FactoryBot.define do
  factory :trait_grade do
    sequence(:trait_grade) {|n| "#{Faker::Lorem.word}_#{n}"}
    description { Faker::Lorem.sentence }
    annotable_no_owner
    trait_descriptor
  end
end
