class QtlJob < ActiveRecord::Base

  has_many :qtls

  include Annotable
end
