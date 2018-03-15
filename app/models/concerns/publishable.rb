module Publishable
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Validations
    include PublishableQueries

    validates_with PublicationValidator

    before_validation -> {
      self.published_on ||= Time.now if published?
    }

    def publish
      return if published?
      update_attributes!(published: true)
    end

    def revoke
      return unless published?
      raise "#{self.class}##{id} cannot be revoked" unless revocable?
      update_attributes!(published: false, published_on: nil)
    end
  end
end
