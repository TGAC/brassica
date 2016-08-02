module ElasticsearchHelper
  def create_index(*klasses)
    klasses.each { |klass| klass.__elasticsearch__.create_index! }
  end

  def delete_index(*klasses)
    klasses.each { |klass| klass.__elasticsearch__.delete_index! }
  end

  def refresh_index(*klasses)
    klasses.each { |klass| klass.__elasticsearch__.refresh_index! }
    wait_for_indexes
  end

  def wait_for_indexes
    client = Elasticsearch::Client.new
    client.cluster.health(wait_for_status: :yellow)
  end
end
