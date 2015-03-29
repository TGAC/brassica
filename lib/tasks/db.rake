namespace :db do
  desc "Prepare DB from zero to production-ready state"
  task :bootstrap => :environment do
    unless ask_for_confirmation
      puts "Exiting."
      next
    end
    puts " - dropping old DB and creating a new one"
    recreate_db
    puts " - loading cropstore DB dump data"
    restore_cropstore_dump
    puts " - initial curation of CS data"
    perform_initial_curation
    puts " - adding new BIP migrations"
    migrate_db
    puts " - loading Gramene and CS taxonomy"
    bootstrap_obo_taxonomy
    puts " - final curation of CS/taxonomy data"
    perform_final_curation
    puts " - DONE"
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
    silence_stdout do
      Rake::Task['curate:purge_empty_tables'].invoke
      Rake::Task['curate:purge_empty_columns'].invoke
      Rake::Task['curate:purge_placeholder_records'].invoke
    end
  end

  def migrate_db
    prepare_db = File.read('db/prepare_db.sql')
    ActiveRecord::Base.connection.execute(prepare_db)

    Rake::Task['db:migrate'].invoke
  end

  def bootstrap_obo_taxonomy
    silence_stdout do
      Rake::Task['obo:taxonomy'].invoke
    end
  end

  def perform_final_curation
    silence_stdout do
      Rake::Task['curate:plant_taxonomy'].invoke
      Rake::Task['curate:fix_sny1'].invoke
      Rake::Task['curate:add_missing_plant_parts'].invoke
    end
  end

  def silence_stdout
    $stdout = File.new( '/dev/null', 'w' )
    yield
  ensure
    $stdout = STDOUT
  end
end
