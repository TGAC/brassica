module Submissions
  class Step02ContentForm < Reform::Form
    property :baz
    property :blah

    validates :baz, presence: true
  end
end
