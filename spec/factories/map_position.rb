FactoryGirl.define do
  factory :map_position do
    sequence(:marker_assay_name) {|n| "#{Faker::Lorem.word}_#{n}"}
    mapping_locus { Faker::Lorem.word }
    map_position { Faker::Lorem.word }
    confirmed_by_whom { Faker::Internet.user_name }
    linkage_group
    population_locus
    marker_assay
    annotable
  end
end
