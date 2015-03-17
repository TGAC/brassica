namespace :curate do
  desc 'Fixes single wrong PlantPopulation -> PlantLine female reference'
  task fix_sny1: :environment do
    sny1pp = PlantPopulation.find_by(female_parent_line: 'SNY1')
    syn1 = PlantLine.find_by(plant_line_name: 'SYN1')
    if sny1pp && syn1
      sny1pp.female_parent_line = syn1
      sny1pp.save
      'Fixed.'
    end
    pl_refs = PlantPopulation.pluck(:female_parent_line, :male_parent_line)
    pl_refs = pl_refs.flatten.uniq.compact
    # This will throw an exception if not found
    pl_refs.each do |ref|
      begin
        PlantLine.find(ref)
      rescue ActiveRecord::RecordNotFound => e
        puts e.message
        next
      end
    end
  end
end
