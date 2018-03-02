FactoryBot.define do
  factory :plant_treatment_type do
    sequence(:name) {|n| "Plant treatment type #{n}"}
    sequence(:term) {|n| "PTT:#{n}" }
  end
end
