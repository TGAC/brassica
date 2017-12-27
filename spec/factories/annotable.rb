FactoryBot.define do
  trait :annotable do
    comments { Faker::Lorem.sentence }
    entered_by_whom { Faker::Internet.user_name }
    date_entered { Faker::Date.backward }
    data_provenance { Faker::Lorem.sentence }
    data_owned_by { Faker::Company.name }
  end

  trait :annotable_no_owner do
    comments { Faker::Lorem.sentence }
    entered_by_whom { Faker::Internet.user_name }
    date_entered { Faker::Date.backward }
    data_provenance { Faker::Lorem.sentence }
  end
end
