module Submissions
  module Trial
    class Step02ContentForm < PlantTrialForm
      property :trait_descriptor_list

      collection :new_trait_descriptors do
        property :descriptor_name
        property :category

        property :units_of_measurements
        property :where_to_score
        property :scoring_method
        property :when_to_score
        property :stage_scored
        property :precautions
        property :materials
        property :controls
        property :calibrated_against
        property :instrumentation_required
        property :likely_ambiguities
        property :score_type
        property :possible_interactions

        property :data_owned_by
        property :data_provenance
        property :comments

        validates :descriptor_name, presence: true
        validates :category, presence: true
      end

      validates :trait_descriptor_list, length: { minimum: 1 }

      # NOTE While descriptor_name is not required by current model to be unique
      #      we should treat it like it is for the purpose of future submissions.
      validate do
        new_trait_descriptors.each do |new_trait_descriptor|
          if trait_descriptor_exists?(descriptor_name: new_trait_descriptor.descriptor_name)
            errors.add(:new_trait_descriptors, :taken, name: new_trait_descriptor.descriptor_name)
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
          unless trait_descriptor_exists?(id: id_or_name) || new_trait_descriptors.map(&:descriptor_name).include?(id_or_name)
            errors.add(:trait_descriptor_list, :blank, name: id_or_name)
          end
        end
      end

      def trait_descriptor_exists?(attrs)
        TraitDescriptor.where(attrs).exists?
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
          :descriptor_name,
          :category,
          :units_of_measurements,
          :where_to_score,
          :scoring_method,
          :when_to_score,
          :stage_scored,
          :precautions,
          :materials,
          :controls,
          :calibrated_against,
          :instrumentation_required,
          :likely_ambiguities,
          :score_type,
          :possible_interactions,
          :data_owned_by,
          :data_provenance,
          :comments
        ]
      end

      def trait_descriptor_list
        super.try { |tdl| tdl.select(&:present?) }
      end

      def new_trait_descriptors
        super || []
      end
    end
  end
end
