module Publishable
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Validations

    validates_with PublicationValidator

    scope :published, -> { where(published: true) }
    scope :not_published, -> { where(published: false) }
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
      published? && Time.now < revocable_until
    end

    def revocable_until
      published_on + 1.week if published?
    end

    def private?
      !(published? || user.nil?)
    end
  end
end
