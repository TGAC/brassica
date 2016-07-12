namespace :curate do
  desc 'Purge all submissions and related records'
  task purge_submissions: :environment do

    sus = Submission::Upload.all
    puts "Found #{sus.length} submission uploads."

    sus.destroy_all

    ss = Submission.all
    puts "Found #{ss.length} submissions."

    ss.destroy_all

    models = Api.writable_models
    models.each do |m|
      if m.column_names.include? 'user_id'
        records = m.where("user_id IS NOT NULL")
        puts "Found #{records.length} records of type #{m.name} with user_id not set to null. Purging."
        records.delete_all
      else
        puts "#{m.name} has no user_id attribute. Skipping."
      end
    end

    puts "Rebuilding ES indices..."
    models.each do |model|
      if model.included_modules.include? Elasticsearch::Model
        puts "...processing model #{model.name}..."
        model.import force: true, refresh: true
      end
    end

    puts "Clearing Rails cache..."
    Rails.cache.clear

    puts "All done."
  end
end
