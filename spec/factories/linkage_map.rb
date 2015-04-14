FactoryGirl.define do
  factory :linkage_map do
    sequence(:linkage_map_label) { Faker::Lorem.characters(10) }
    sequence(:linkage_map_name) { Faker::Lorem.characters(10) }
    map_version_no { Faker::Number.number(3).to_s }
    map_version_date { Faker::Date.backward }
    mapping_software { Faker::Lorem.words(3) }
    mapping_function { Faker::Lorem.word }
    map_author { Faker::Internet.user_name }
    confirmed_by_whom { Faker::Internet.user_name }
    instance_eval &AnnotableFactory.annotated
    plant_population
  end
end
