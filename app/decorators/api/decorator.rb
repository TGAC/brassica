# NOTE it does not do anything at this moment but will be used to expose
# associations
class Api::Decorator < Draper::Decorator
  delegate_all

  def as_json(*)
    super.merge(associations_as_json)
  end

  def associations_as_json
    {}.tap do |json|
      object.class.reflections.each do |association, reflection|
        next if reflection.is_a?(ActiveRecord::Reflection::BelongsToReflection) # These are already included
        next if blacklisted_has_many_association?(association)

        association_klass = (reflection.options[:class_name] || association.classify).constantize
        primary_key = reflection.options[:primary_key] || association_klass.primary_key

        next unless primary_key # Skip associations with join tables used by HABTM

        attr = "#{association}_#{primary_key.to_s.pluralize}"

        json[attr] = object.send(association).pluck(primary_key)
      end
    end
  end

  private

  def blacklisted_has_many_association?(name)
    %w(User Submission ApiKey).include?(name.classify)
  end
end
