FactoryBot.define do
  factory :map_position do
    sequence(:marker_assay_name) {|n| "#{Faker::Lorem.word}_#{n}"}
    mapping_locus { Faker::Lorem.word }
    map_position { Faker::Lorem.word }
    confirmed_by_whom { Faker::Internet.user_name }
    published_on { Date.today-8.days }
    linkage_group
    population_locus
    marker_assay
    user
    annotable
  end
end
