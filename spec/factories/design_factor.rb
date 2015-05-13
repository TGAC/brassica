FactoryGirl.define do
  factory :design_factor do
    sequence(:design_factor_name) {|n| "#{Faker::Lorem.characters(20)}_#{n}"}
    institute_id { Faker::Company.name }
    trial_location_name { Faker::Lorem.sentence }
    design_unit_counter { Faker::Number.number(3).to_s }
    design_factor_1 { 'rep_' + Faker::Number.number(1).to_s }
    design_factor_2 { 'block_' + Faker::Number.number(1).to_s }
    design_factor_3 { 'row_' + Faker::Number.number(1).to_s }
    design_factor_4 { 'col_' + Faker::Number.number(2).to_s }
    design_factor_5 { 'plot_' + Faker::Number.number(3).to_s }
    confirmed_by_whom { Faker::Internet.user_name }
    annotable
  end
end
