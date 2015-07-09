FactoryGirl.define do
  factory :population_locus do
    sequence(:mapping_locus) {|n| "#{Faker::Lorem.characters(5)}_#{n}"}
    defined_by_whom { Faker::Internet.user_name }
    plant_population
    marker_assay
    user
    annotable
  end
end
