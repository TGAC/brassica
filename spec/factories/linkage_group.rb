FactoryGirl.define do
  factory :linkage_group do
    sequence(:linkage_group_label) {|n| "#{Faker::Lorem.characters(5)}_#{n}"}
    sequence(:linkage_group_name) { Faker::Lorem.characters(10) }
    total_length { Faker::Number.number(3).to_s }
    lod_threshold { Faker::Number.number(3).to_s }
    consensus_group_assignment { Faker::Lorem.word }
    consensus_group_orientation { Faker::Lorem.word }
    confirmed_by_whom { Faker::Internet.user_name }
    published_on { Date.today-8.days }
    linkage_map
    user
    annotable
  end
end
