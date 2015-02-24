module Submissions
  class Step02ContentForm < BaseForm
    property :baz
    property :blah

    validates :baz, presence: true
  end
end
