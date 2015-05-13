class Api::Decorator < Draper::Decorator
  delegate_all

  def as_json(*)
    super.merge(associations_as_json)
  end

  def associations_as_json
    {}.tap do |json|
      associations = Api::AssociationFinder.new(object.class).has_many_associations
      associations.each do |association|
        attr = "#{association.name}_#{association.primary_key.to_s.pluralize}"

        json[attr] = object.send(association.name).pluck(association.primary_key)
      end
    end
  end

end
