namespace :curate do
  desc 'Purge all submissions and related records'
  task purge_submissions: :environment do

    ss = Submission.all
    puts "Found #{ss.length} submissions."

    ss.each do |s|
      s.destroy
    end

    sus = Submission::Upload.all
    puts "Found #{sus.length} submission uploads."

    sus.each do |su|
      su.destroy
    end

    models = ActiveRecord::Base.descendants

    models.each do |m|
      if m.column_names.include? 'user_id'
        records = m.where("user_id IS NOT NULL")
        puts "Found #{records.length} records of type #{m.name} with user_id not set to null. Purging."
        records.each do |r|
          r.delete
        end
      else
        puts "#{m.name} has no user_id attribute. Skipping."
      end
    end

    puts "Rebuilding ES indices..."
    %x( curl -XPOST 'http://localhost:9200/_refresh' )

    puts "Clearing Rails cache..."
    Rails.cache.clear

    puts "All done."
  end
end
