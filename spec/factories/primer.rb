FactoryGirl.define do
  factory :primer do
    sequence(:primer) {|n| "#{Faker::Lorem.word}_#{n}"}
    sequence_id { Faker::Number.number(7).to_s }
    sequence_source_acronym { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    annotable

    after(:build) do |primer_registry, _|
      primer_registry.sequence = 'GATTACA'
    end
  end
end
