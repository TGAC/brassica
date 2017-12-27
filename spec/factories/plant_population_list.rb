FactoryBot.define do
  factory :plant_population_list do
    published_on { Date.today-8.days }
    sort_order '1'
    plant_population
    plant_line
    user
    annotable_no_owner
  end
end
