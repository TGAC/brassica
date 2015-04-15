FactoryGirl.define do
  factory :linkage_group do
    sequence(:linkage_group_label) { Faker::Lorem.characters(10) }
    sequence(:linkage_group_name) { Faker::Lorem.characters(10) }
    total_length { Faker::Number.number(3).to_s }
    lod_threshold { Faker::Number.number(3).to_s }
    consensus_group_assignment { Faker::Lorem.word }
    consensus_group_orientation { Faker::Lorem.word }
    confirmed_by_whom { Faker::Internet.user_name }
    instance_eval &AnnotableFactory.annotated
  end
end
