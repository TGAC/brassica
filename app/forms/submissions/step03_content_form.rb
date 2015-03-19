module Submissions
  class Step03ContentForm < BaseForm
    extend ModelHelper

    property :female_parent_line
    property :male_parent_line
    property :plant_line_list

    validates :female_parent_line, inclusion: { in: plant_lines, allow_blank: true }
    validates :male_parent_line, inclusion: { in: plant_lines, allow_blank: true }

    collection :new_plant_lines do
      property :plant_line_name
      property :taxonomy_term
      property :common_name
      property :previous_line_name
      property :comments
      property :genetic_status

      validates :plant_line_name, presence: true
      validates :taxonomy_term, inclusion: { in: TaxonomyTerm.names }
    end

    # Do not allow :new_plant_lines to include existing :plant_line_name
    validate do
      new_plant_lines.each do |new_plant_line|
        if plant_line_exists?(new_plant_line.plant_line_name)
          errors.add(:new_plant_lines, "#{new_plant_line.plant_line_name} already exists in our database")
        end
      end
    end

    # Ensure all items in :plant_line_list either exist or have
    # valid entries in :new_plant_lines:w
    validate do
      plant_line_list.each do |name|
        unless plant_line_exists?(name) || new_plant_lines.map(&:plant_line_name).include?(name)
          errors.add(:plant_line_list, "#{name} is not defined")
        end
      end
    end

    def plant_line_exists?(name)
      PlantLine.where(plant_line_name: name).exists?
    end

    def self.permitted_properties
      [
        :female_parent_line, :male_parent_line,
        {
          :plant_line_list => [],
          :new_plant_lines => [
            :plant_line_name,
            :taxonomy_term,
            :common_name,
            :previous_line_name,
            :comments,
            :genetic_status
          ]
        }
      ]
    end

    def plant_line_list
      super.try { |pll| pll.select(&:present?) }
    end

    def new_plant_lines
      super || []
    end

  end
end
