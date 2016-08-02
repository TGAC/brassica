class Search::IndexBuilder
  def call(klass)
    klass.__elasticsearch__.delete_index!
    klass.__elasticsearch__.create_index!

    klass.published.find_each { |record| record.__elasticsearch__.index_document }

    klass.__elasticsearch__.refresh_index!
  end
end
