FactoryGirl.define do
  factory :plant_population_list do
    sort_order '1'
    plant_population
    plant_line
    user
    annotable_no_owner
  end
end
