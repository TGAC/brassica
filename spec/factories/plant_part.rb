FactoryGirl.define do
  factory :plant_part do
    sequence(:plant_part) {|n| "#{Faker::Lorem.word}_#{n}"}
    description { Faker::Lorem.sentence }
    label { "PO:#{Faker::Number.number(7)}" }
    canonical { true }
    described_by_whom { Faker::Internet.user_name }
    confirmed_by_whom { Faker::Internet.user_name }
    annotable_no_owner
  end
end
