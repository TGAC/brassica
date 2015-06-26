class Api::AssociationFinder

  attr_accessor :klass

  def initialize(klass)
    self.klass = klass
  end

  def has_many_associations
    association_reflections(:has_many, :through).map do |association_name, reflection|
      association_data(association_name, reflection)
    end
  end

  def has_and_belongs_to_many_associations
    association_reflections(:has_and_belongs_to_many).map do |association_name, reflection|
      association_data(association_name, reflection)
    end
  end

  private

  def association_reflections(*types)
    klass.reflections.select do |association_name, reflection|
      !blacklisted_association?(association_name) && types.any? do |type|
        reflection.is_a?("ActiveRecord::Reflection::#{type.to_s.classify}Reflection".constantize)
      end
    end
  end

  def association_data(association_name, reflection)
    association_klass = (reflection.options[:class_name] || association_name.singularize.classify).constantize
    primary_key = reflection.options[:primary_key] || association_klass.primary_key

    OpenStruct.new(
      name: association_name,
      primary_key: primary_key,
      param: "#{association_name.singularize}_#{primary_key.to_s.pluralize}",
      klass: association_klass
    )
  end

  def blacklisted_association?(association_name)
    %w(User Submission ApiKey).include?(association_name.singularize.classify)
  end
end
