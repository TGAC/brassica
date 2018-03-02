FactoryBot.define do
  factory :measurement_unit do
    sequence(:name) { |n| "Measurement unit #{n}"}
    sequence(:term) { |n| "MU:#{n}" }
    description { |attrs| "Description of #{attrs.name}" }
  end
end
