class BaseForm < Reform::Form

  class_attribute :permitted_properties

  def self.property(name, options={}, &block)
    self.permitted_properties ||= []
    self.permitted_properties << name
    super
  end

  def self.collection(name, options={}, &block)
    self.permitted_properties ||= []

    collection_props = self.permitted_properties.find { |prop| prop.is_a?(Hash) } || {}
    collection_props[name] =
      if block.nil?
        # collection of scalars
        []
      else
        # collection of hashes - not supported here, need to overload permitted_properties
        # on subclass
      end

    unless self.permitted_properties.include?(collection_props)
      self.permitted_properties << collection_props
    end

    super
  end
end
