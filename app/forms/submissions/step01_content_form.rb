module Submissions
  class Step01ContentForm < Reform::Form
    property :foo
    property :bar

    validates :foo, length: { minimum: 10 }
  end
end
