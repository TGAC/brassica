module Submissions
  class Step01ContentForm < BaseForm
    property :name
    property :description
    property :owned_by

    validates :name, presence: true
  end
end
