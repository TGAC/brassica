module Submissions
  class Step01ContentForm < BaseForm
    property :foo
    property :bar

    validates :foo, length: { minimum: 10 }
  end
end
