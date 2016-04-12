module Publishable
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Validations

    validates_with PublicationValidator

    scope :visible, ->(uid = nil) {
      condition = "#{table_name}.user_id IS NULL OR #{table_name}.published = TRUE"
      condition += " OR #{table_name}.user_id = #{uid}" if uid
      where condition
    }

    scope :hidden, ->(uid = nil) {
      condition = "#{table_name}.published = FALSE"
      condition += " AND #{table_name}.user_id <> #{uid}" if uid
      where condition
    }

    def revocable?
      !published? || (published_on > Time.now - 1.week)
    end
  end
end
