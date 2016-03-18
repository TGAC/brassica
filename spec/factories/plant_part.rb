FactoryGirl.define do
  factory :plant_part do
    sequence(:plant_part) {|n| "#{Faker::Lorem.word}_#{n}"}
    description { Faker::Lorem.sentence }
    described_by_whom { Faker::Internet.user_name }
    confirmed_by_whom { Faker::Internet.user_name }
    published_on { Date.today-8.days }
    annotable_no_owner
  end
end
