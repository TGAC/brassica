FactoryGirl.define do
  factory :plant_line do
    sequence(:plant_line_name) {|n| "#{Faker::Lorem.word}_#{n}"}
    common_name { Faker::Lorem.word }
    previous_line_name { Faker::Lorem.word }
    date_entered { Faker::Date.backward }
    data_owned_by { Faker::Company.name }
    comments { Faker::Lorem.sentence }
    data_provenance { Faker::Lorem.sentence }
    taxonomy_term
  end
end
