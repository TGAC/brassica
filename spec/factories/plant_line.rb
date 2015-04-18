FactoryGirl.define do
  factory :plant_line do
    sequence(:plant_line_name) {|n| "#{Faker::Lorem.characters(5)}_#{n}"}
    common_name { Faker::Lorem.word }
    previous_line_name { Faker::Lorem.word }
    taxonomy_term
    annotable
  end
end
