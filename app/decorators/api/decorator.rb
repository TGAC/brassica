class Api::Decorator < Draper::Decorator
  delegate_all

  def as_json(*)
    super(object.class.try(:json_options)).
      reject do |k,v|
        blacklisted_attrs.include?(k) || k.end_with?('_count')
      end.
      merge(associations_as_json)
  end

  def associations_as_json
    {}.tap do |json|
      associations = Api::AssociationFinder.new(object.class).has_many_associations
      associations.each do |association|
        json[association.param] = object.send(association.name).pluck(association.primary_key)
      end
    end
  end

  private

  def blacklisted_attrs
    %w(user_id created_at updated_at)
  end

end
