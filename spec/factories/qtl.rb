FactoryGirl.define do
  factory :qtl do
    sequence(:qtl_rank) { Faker::Lorem.characters(14) }
    sequence(:map_qtl_label) { Faker::Lorem.characters(14) }
    inner_interval_end { Faker::Number.number(4).to_s }
    outer_interval_start { Faker::Number.number(4).to_s }
    peak_value { Faker::Number.number(2).to_s }
    peak_p_value { Faker::Number.number(2).to_s }
    regression_p { Faker::Number.number(2).to_s }
    residual_p { Faker::Number.number(2).to_s }
    additive_effect { Faker::Lorem.sentence }
    genetic_variance_explained { Faker::Lorem.sentence }
    pubmed_id { Faker::Number.number(7) }
    annotable
    linkage_group
    processed_trait_dataset
  end
end
