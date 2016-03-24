FactoryGirl.define do
  factory :marker_assay do
    sequence(:marker_assay_name) {|n| "#{Faker::Lorem.word}_#{n}"}
    canonical_marker_name { Faker::Lorem.word }
    separation_system { Faker::Lorem.words(3) }
    marker_type { Faker::Lorem.word }
    published_on { Date.today-8.days }
    annotable
    user
    probe
    association :primer_a, factory: :primer
    association :primer_b, factory: :primer
  end
end
