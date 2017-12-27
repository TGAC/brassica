FactoryBot.define do
  factory :genotype_matrix do
    sequence(:original_file_name) {|n| "#{Faker::Lorem.characters(12)}_#{n}"}
    date_matrix_available { Faker::Date.backward }
    matrix_compiled_by { Faker::Internet.user_name }
    number_markers_in_matrix { Faker::Number.number(2) }
    number_lines_in_matrix { Faker::Number.number(3) }
    matrix { Faker::Lorem.characters(200) }
    annotable
    linkage_map
  end
end
