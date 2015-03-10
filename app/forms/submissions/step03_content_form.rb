module Submissions
  class Step03ContentForm < BaseForm
    extend ModelHelper

    property :female_parent_line
    property :male_parent_line
    property :plant_line_list

    validates :female_parent_line, inclusion: { in: plant_lines, allow_blank: true }
    validates :male_parent_line, inclusion: { in: plant_lines, allow_blank: true }

    def self.permitted_properties
      [:female_parent_line, :male_parent_line, { :plant_line_list => [] }]
    end

    def plant_line_list
      super.try { |pll| pll.select(&:present?) }
    end
  end
end
