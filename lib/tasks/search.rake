namespace :search do
  namespace :reindex do
    desc "Destroy, recreate and populate index with public records"
    task model: :environment do
      klass_name = ENV.fetch("CLASS") { puts "Missing CLASS=<class name>"; exit }
      klass = klass_name.classify.constantize

      Search::IndexBuilder.new.call(klass)
    end
  end
end
