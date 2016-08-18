namespace :search do
  namespace :reindex do
    desc "Destroy, recreate and populate ES indices with public records"
    task :all do
      on roles(:app), in: :groups, limit: 1, wait: 10 do
        within release_path do
          klasses = %w(
            PlantLine PlantPopulation PlantVariety LinkageGroup LinkageMap
            MapPosition MapLocusHit PopulationLocus MarkerAssay Primer
            Probe PlantTrial Qtl TraitDescriptor PlantScoringUnit
            PlantAccession QtlJob
          )

          klasses.each do |klass|
            execute :rake, "search:reindex:model CLASS='#{klass}'"
          end
        end
      end
    end
  end
end
