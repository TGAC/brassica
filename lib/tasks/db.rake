namespace :db do
  desc "Prepare DB from zero to production-ready state"
  task :bootstrap => :environment do
    unless ask_for_confirmation
      puts "Exiting."
      next
    end
    recreate_db
    restore_cropstore_dump
    perform_initial_curation
    migrate_db
    bootstrap_obo_taxonomy
    perform_final_curation
  end

  def ask_for_confirmation
    print "This will drop and recreate database resulting in potential data loss.\n"
    print "Are you sure? (y/n): "
    $stdin.getc.downcase == 'y'
  end

  def recreate_db
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
  end

  def restore_cropstore_dump
    db_config = Rails.application.config_for(:database)
    env = { "PGUSER" => db_config["username"], "PGPASSWORD" => db_config["password"] }
    cmd = "pg_restore -O -d #{db_config["database"]} db/cropstore_web_pg.dump"
    unless system(env, cmd)
      raise "Cropstore dump restoration failed: #{$?}"
    end
  end

  def perform_initial_curation
    Rake::Task['curate:purge_empty_tables'].invoke
    Rake::Task['curate:purge_empty_columns'].invoke
    Rake::Task['curate:purge_placeholder_records'].invoke
  end

  def migrate_db
    prepare_db = File.read('db/prepare_db.sql')
    ActiveRecord::Base.connection.execute(prepare_db)

    Rake::Task['db:migrate'].invoke
  end

  def bootstrap_obo_taxonomy
    Rake::Task['obo:taxonomy'].invoke
  end

  def perform_final_curation
    Rake::Task['curate:plant_taxonomy'].invoke
    Rake::Task['curate:fix_sny1'].invoke
    Rake::Task['curate:add_missing_plant_parts'].invoke
  end
end
