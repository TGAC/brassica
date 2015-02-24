class BaseForm < Reform::Form

  class_attribute :permitted_properties

  def self.property(name, options={}, &block)
    self.permitted_properties ||= []
    self.permitted_properties << name
    super
  end

end
