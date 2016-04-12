module Publishable
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Validations

    validates_with PublicationValidator

    scope :published, -> { where(published: true) }
    scope :not_published, -> { where(published: false) }
    scope :visible, ->(uid = nil) {
      if uid.present?
        where("published = 't' OR user_id = #{uid}")
      else
        where("published = 't' OR user_id IS NULL")
      end
    }

    def revocable?
      published? && Time.now < revocable_until
    end

    def revocable_until
      published_on + 1.week if published?
    end
  end
end
