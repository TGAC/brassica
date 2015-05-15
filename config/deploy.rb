# config valid only for current version of Capistrano
lock '3.3.5'

set :application, 'brassica'
set :repo_url, 'ssh://git@github.com/eSpectrum-IT/brassica.git'

set :deploy_to, '/var/www/brassica'
set :scm, :git

# Default branch is :master
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

set :puma_conf, "#{shared_path}/config/puma.rb"
set :chruby_ruby, 'ruby-2.2.1'

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/puma.rb', '.env')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
set :default_env, {
  # NOTE Adding ruby dir to path should not be required but it seems capistrano-chruby does
  # not do its job...
  path: "/opt/rubies/ruby-2.2.1/bin:$PATH"
}

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  after :finished, :rebuild_indices do
    on roles(:app), in: :groups, limit: 1, wait: 10 do
      within release_path do
        execute :rake, "environment elasticsearch:import:model CLASS='PlantLine' FORCE=y"
        execute :rake, "environment elasticsearch:import:model CLASS='PlantPopulation' FORCE=y"
        execute :rake, "environment elasticsearch:import:model CLASS='PlantVariety' FORCE=y"
        execute :rake, "environment elasticsearch:import:model CLASS='LinkageGroup' FORCE=y"
        execute :rake, "environment elasticsearch:import:model CLASS='LinkageMap' FORCE=y"
        execute :rake, "environment elasticsearch:import:model CLASS='MapPosition' FORCE=y"
        execute :rake, "environment elasticsearch:import:model CLASS='MapLocusHit' FORCE=y"
        execute :rake, "environment elasticsearch:import:model CLASS='PopulationLocus' FORCE=y"
        execute :rake, "environment elasticsearch:import:model CLASS='MarkerAssay' FORCE=y"
        execute :rake, "environment elasticsearch:import:model CLASS='Primer' FORCE=y"
        execute :rake, "environment elasticsearch:import:model CLASS='Probe' FORCE=y"
        execute :rake, "environment elasticsearch:import:model CLASS='PlantTrial' FORCE=y"
        execute :rake, "environment elasticsearch:import:model CLASS='Qtl' FORCE=y"
        execute :rake, "environment elasticsearch:import:model CLASS='TraitDescriptor' FORCE=y"
      end
    end
  end
end
