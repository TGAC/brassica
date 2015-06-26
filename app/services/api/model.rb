class Api::Model

  attr_accessor :name, :klass

  def initialize(name)
    self.name = name
    self.klass = name.classify.constantize
  end

end
