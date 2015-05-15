FactoryGirl.define do
  factory :linkage_map do
    sequence(:linkage_map_label) {|n| "#{Faker::Lorem.characters(5)}_#{n}"}
    sequence(:linkage_map_name) { Faker::Lorem.characters(10) }
    map_version_no { Faker::Number.number(3).to_s }
    map_version_date { Faker::Date.backward }
    mapping_software { Faker::Lorem.words(3) }
    mapping_function { Faker::Lorem.word }
    map_author { Faker::Internet.user_name }
    pubmed_id { Faker::Number.number(7) }
    confirmed_by_whom { Faker::Internet.user_name }
    annotable
    plant_population
  end
end
