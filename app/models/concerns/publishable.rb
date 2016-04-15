module Publishable
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Validations

    validates_with PublicationValidator

    scope :visible, ->(uid = nil) {
      if uid.present?
        where("published = 't' OR user_id = #{uid}")
      else
        where("published = 't' OR user_id IS NULL")
      end
    }

    def revocable?
      !published? || (published_on > Time.now - 1.week)
    end

    def private?
      !(published? || user.nil?)
    end
  end
end
