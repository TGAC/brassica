class SearchResultsDecorator

  attr_accessor :options

  def initialize(options)
    self.options = options
  end

  def as_autocomplete_data
    data = options.fetch(:counts)
    data.map { |model, count| {
      model: model.to_s,
      count: count,
      message: I18n.t("search.#{model}_count", count: count)
    } }
  end
end
