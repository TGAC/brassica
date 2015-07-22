module Submissions
  module Population
    class Step03ContentForm < PlantPopulationForm
      property :female_parent_line
      property :male_parent_line
      property :plant_line_list

      validates :female_parent_line, :male_parent_line, inclusion: {
        in: PlantLine.pluck(:plant_line_name),
        allow_blank: true
      }

      collection :new_plant_lines do
        property :plant_line_name
        property :taxonomy_term
        property :common_name
        property :previous_line_name
        property :genetic_status
        property :plant_variety_name
        property :data_owned_by
        property :data_provenance
        property :comments

        validates :plant_line_name, presence: true
        validates :taxonomy_term, inclusion: { in: TaxonomyTerm.names }
      end

      # Do not allow :new_plant_lines to include existing :plant_line_name
      validate do
        new_plant_lines.each do |new_plant_line|
          if plant_line_exists?("plant_line_name ILIKE ?", new_plant_line.plant_line_name)
            errors.add(:new_plant_lines, :taken, name: new_plant_line.plant_line_name)
          end
        end
      end

      validate do
        duplicated_plant_lines =
          Hash[plant_line_list.map { |pl| [pl, plant_line_list.count(pl)] }].
          select { |pl, count| count > 1 }.
          keys

        duplicated_plant_lines.each do |plant_line|
          errors.add(:plant_line_list, :duplicated, name: plant_line)
        end
      end

      # Ensure all items in :plant_line_list either exist or have
      # valid entries in :new_plant_lines
      validate do
        plant_line_list.each do |id_or_name|
          unless plant_line_exists?(id: id_or_name) || new_plant_lines.map(&:plant_line_name).include?(id_or_name)
            errors.add(:plant_line_list, :blank, name: id_or_name)
          end
        end
      end

      def plant_line_exists?(*attrs)
        PlantLine.where(*attrs).exists?
      end

      def existing_plant_lines
        ids = plant_line_list.try(:map, &:to_i)
        PlantLine.where(id: ids)
      end

      def self.permitted_properties
        [
          :female_parent_line, :male_parent_line,
          {
            :plant_line_list => [],
            :new_plant_lines => new_plant_line_properties
          }
        ]
      end

      def self.new_plant_line_properties
        [
          :plant_line_name,
          :taxonomy_term,
          :common_name,
          :previous_line_name,
          :genetic_status,
          :plant_variety_name,
          :data_owned_by,
          :data_provenance,
          :comments,
        ]
      end

      def plant_line_list
        super.try { |pll| pll.select(&:present?) }
      end

      def new_plant_lines
        (super || []).select do |plant_line|
          plant_line_list.include?(plant_line.plant_line_name)
        end
      end
    end
  end
end
