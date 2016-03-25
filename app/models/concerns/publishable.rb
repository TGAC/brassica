module Publishable
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Validations

    validates_with PublicationValidator

    def revocable?
      !published? || (published_on > Time.now - 1.week)
    end
  end
end
