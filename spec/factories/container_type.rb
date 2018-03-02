FactoryBot.define do
  factory :container_type do
    sequence(:name) { |n| "Container type #{n}"}
  end
end
