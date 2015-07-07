module AttributeValues extend ActiveSupport::Concern
  included do
    def self.attribute_values(attr)
      raise ArgumentError, "Invalid attr: #{attr}" unless attribute_names.include?(attr.to_s)

      where("#{attr} IS NOT NULL").pluck("DISTINCT #{attr}")
    end
  end
end
