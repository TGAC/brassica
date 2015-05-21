class Api::AssociationFinder

  attr_accessor :klass

  def initialize(klass)
    self.klass = klass
  end

  def has_many_associations
    klass.reflections.map do |association, reflection|
      next if reflection.is_a?(ActiveRecord::Reflection::BelongsToReflection)
      next if blacklisted_has_many_association?(association)
      next if klass.respond_to?(:json_options) && klass.json_options[:include].include?(association.to_sym)

      association_klass = (reflection.options[:class_name] || association.classify).constantize
      primary_key = reflection.options[:primary_key] || association_klass.primary_key

      next unless primary_key # Skip associations with join tables used by HABTM

      OpenStruct.new(
        name: association,
        primary_key: primary_key,
        param: "#{association}_#{primary_key.to_s.pluralize}",
        class_name: association_klass.name

      )
    end.compact
  end

  private

  def blacklisted_has_many_association?(name)
    %w(User Submission ApiKey).include?(name.classify)
  end
end
