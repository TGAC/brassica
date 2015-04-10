FactoryGirl.define do
  factory :plant_population_list do
    sort_order '1'
    instance_eval &AnnotableFactory.annotated_no_owner
  end
end
