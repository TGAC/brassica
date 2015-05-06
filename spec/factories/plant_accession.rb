FactoryGirl.define do
  factory :plant_accession do
    sequence(:plant_accession) { |n| "#{Faker::Lorem.characters(12)}_#{n}" }
    plant_accession_derivation { Faker::Lorem.word }
    accession_originator { Faker::Internet.email }
    originating_organisation { Faker::Company.name }
    year_produced { Faker::Date.backward.year.to_s }
    date_harvested { Faker::Date.backward }
    # TODO FIXME these two have to wait for #204 fix
    # t.text    "female_parent_plant_id"
    # t.text    "male_parent_plant_id"
    confirmed_by_whom { Faker::Internet.user_name }
    plant_line
    annotable
  end
end
