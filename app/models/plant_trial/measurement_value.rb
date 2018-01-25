class PlantTrial::MeasurementValue < ActiveRecord::Base
  def self.environment_properties
    @environment_properties ||= PlantTrial::Environment.measured_properties.keys
  end

  def self.treatment_properties
    @treatment_properties ||= PlantTrial::Treatment.measured_properties.keys
  end

  belongs_to :context, polymorphic: true

  validates :context, :value, presence: true
  validates :property, inclusion: { in: (environment_properties + treatment_properties).map(&:to_s) }
  validate :check_constraints

  def constraints
    read_attribute(:constraints) || {}
  end

  private

  # Perform custom validations defined by #constraints attribute
  def check_constraints
    constraints.each { |name, options| check_constraint(name, options) }
  end

  def check_constraint(name, options)
    default_options = { attributes: [:value] }
    options = (options == true) ? default_options : options.merge(default_options)

    validator_klass(name).new(options).validate(self)
  end

  def validator_klass(name)
    "#{name.classify}Validator".constantize rescue "ActiveModel::Validations::#{name.classify}Validator".constantize
  end
end
