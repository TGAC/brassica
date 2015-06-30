module Submissions
  module Trial
    class Step02ContentForm < PlantTrialForm
      property :trait_descriptor_list

      collection :new_trait_descriptors do
        property :descriptor_name
        property :category
        property :data_owned_by
        property :data_provenance
        property :comments

        validates :descriptor_name, presence: true
        validates :category, presence: true
      end

      # NOTE While descriptor_name is not required by current model to be unique
      #      we should treat it like it is for the purpose of future submissions.

      # Ensure all items in :trait_descriptor_list either exist or have
      # valid entries in :new_trait_descriptors
      validate do
        trait_descriptor_list.each do |name|
          unless trait_descriptor_exists?(name) || new_trait_descriptors.map(&:descriptor_name).include?(name)
            errors.add(:trait_descriptor_list, :blank, name: name)
          end
        end
      end

      def trait_descriptor_exists?(name)
        TraitDescriptor.where("descriptor_name ILIKE ?", name).exists?
      end

      def self.permitted_properties
        [
          {
            :trait_descriptor_list => [],
            :new_trait_descriptors => [
              :descriptor_name,
              :category,
              :data_owned_by,
              :data_provenance,
              :comments
            ]
          }
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
