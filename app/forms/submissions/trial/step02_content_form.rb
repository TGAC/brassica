module Submissions
  module Trial
    class Step02ContentForm < PlantTrialForm
      property :trait_descriptor_list

      collection :new_trait_descriptors do
        # TODO: rename to trait_id
        property :trait
        property :trait_name
        property :plant_part_id
        property :units_of_measurements

        property :scoring_method
        property :materials

        property :data_owned_by
        property :data_provenance
        property :comments

        validates :trait, presence: true
        validates :units_of_measurements, presence: true
        validates :scoring_method, presence: true
      end

      validates :trait_descriptor_list, length: { minimum: 1 }

      # NOTE Left here for the moment we allow users to define their own trait names.
      validate do
        new_trait_descriptors.each do |new_trait_descriptor|
          if trait_descriptor_exists?("traits.name ILIKE ?", new_trait_descriptor.trait_name)
            errors.add(:new_trait_descriptors, :taken, name: new_trait_descriptor.trait_name)
          end
        end
      end

      validate do
        duplicated_trait_descriptors =
          Hash[trait_descriptor_list.map { |td| [td, trait_descriptor_list.count(td)] }].
          select { |td, count| count > 1 }.
          keys

        duplicated_trait_descriptors.each do |trait_descriptor|
          errors.add(:trait_descriptor_list, :duplicated, name: trait_descriptor)
        end
      end

      # Ensure all items in :trait_descriptor_list either exist or have
      # valid entries in :new_trait_descriptors
      validate do
        trait_descriptor_list.each do |id_or_name|
          unless trait_descriptor_exists?(id: id_or_name) || new_trait_descriptors.map(&:trait_name).include?(id_or_name)
            errors.add(:trait_descriptor_list, :blank, name: id_or_name)
          end
        end
      end

      def trait_descriptor_exists?(*attrs)
        TraitDescriptor.includes(:trait).where(*attrs).exists?
      end

      def existing_trait_descriptors
        ids = trait_descriptor_list.try(:map, &:to_i)
        TraitDescriptor.where(id: ids)
      end

      def self.permitted_properties
        [
          {
            :trait_descriptor_list => [],
            :new_trait_descriptors => new_trait_descriptor_properties
          }
        ]
      end

      def self.new_trait_descriptor_properties
        [
          :trait,
          :trait_name,
          :plant_part_id,
          :units_of_measurements,
          :scoring_method,
          :materials,
          :data_owned_by,
          :data_provenance,
          :comments
        ]
      end

      def trait_descriptor_list
        super.try { |tdl| tdl.select(&:present?) }
      end

      def new_trait_descriptors
        (super || []).select do |trait_descriptor|
          trait_descriptor_list.include?(trait_descriptor.trait_name)
        end
      end
    end
  end
end
