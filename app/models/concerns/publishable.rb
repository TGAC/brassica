module Publishable
  extend ActiveSupport::Concern

  included do
    def revocable?
      !published? || (published_on > Time.now - 1.week)
    end
  end
end
