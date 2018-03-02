FactoryBot.define do
  factory :lamp_type do
    sequence(:name) { |n| "Lamp type #{n}"}
  end
end
