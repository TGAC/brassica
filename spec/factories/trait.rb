FactoryGirl.define do
  factory :trait do
    sequence(:name) {|n| "#{Faker::Lorem.word}_#{n}"}
    description { Faker::Lorem.sentence }
    label { "PO:#{Faker::Number.number(7)}" }
  end
end
