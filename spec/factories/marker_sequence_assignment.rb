FactoryGirl.define do
  factory :marker_sequence_assignment do
    sequence(:marker_set) {|n| "#{Faker::Lorem.word}_#{n}"}
    canonical_marker_name { Faker::Lorem.word }
    associated_sequence_id { Faker::Number.number(7).to_s }
    sequence_source_acronym { Faker::Lorem.word }
    published_on { Date.today-8.days }
    annotable
  end
end
