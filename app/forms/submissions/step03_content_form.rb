module Submissions
  class Step03ContentForm < BaseForm
    extend ModelHelper

    property :female_parent_line
    property :male_parent_line

    validates :female_parent_line, inclusion: { in: plant_lines, allow_blank: true }
    validates :male_parent_line, inclusion: { in: plant_lines, allow_blank: true }

  end
end
