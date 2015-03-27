FactoryGirl.define do
  factory :plant_population_list do
    sort_order 1
    comments { Faker::Lorem.sentence }
    entered_by_whom { Faker::Internet.email }
    data_provenance { Faker::Lorem.sentence }
  end
end
