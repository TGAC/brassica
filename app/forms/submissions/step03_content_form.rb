module Submissions
  class Step03ContentForm < BaseForm
    extend ModelHelper

    property :female_parent_line
    property :male_parent_line
    property :plant_line_list

    property :plant_line_name
    property :plant_line_taxonomy_term
    property :plant_line_common_name
    property :plant_line_previous_line_name
    property :plant_line_comments
    property :plant_line_genetic_status

    validates :female_parent_line, inclusion: { in: plant_lines, allow_blank: true }
    validates :male_parent_line, inclusion: { in: plant_lines, allow_blank: true }

    def self.permitted_properties
      [
        :female_parent_line, :male_parent_line,
        :plant_line_name, :plant_line_taxonomy_term, :plant_line_common_name,
        :plant_line_previous_line_name, :plant_line_comments, :plant_line_genetic_status,
        { :plant_line_list => [] }
      ]
    end

    def plant_line_list
      super.try { |pll| pll.select(&:present?) }
    end
  end
end
