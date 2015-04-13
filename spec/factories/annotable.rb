module AnnotableFactory
  def self.annotated
    Proc.new {
      comments { Faker::Lorem.sentence }
      entered_by_whom { Faker::Internet.user_name }
      date_entered { Faker::Date.backward }
      data_provenance { Faker::Lorem.sentence }
      data_owned_by { Faker::Company.name }
    }
  end

  def self.annotated_no_owner
    Proc.new {
      comments { Faker::Lorem.sentence }
      entered_by_whom { Faker::Internet.user_name }
      date_entered { Faker::Date.backward }
      data_provenance { Faker::Lorem.sentence }
    }
  end
end
