require "#{Rails.root}/lib/tasks/task_helpers"

namespace :curate do
  task add_missing_plant_parts: :environment do

    pp = PlantPart.new(plant_part: 'whole plant',
                       description: 'whole plant',
                       described_by_whom: 'pierre.carion@bbsrc.ac.uk',
                       comments: 'no comment',
                       entered_by_whom: 'pierre.carion@bbsrc.ac.uk',
                       date_entered: '2015-03-21',
                       data_provenance: 'n/a',
                       confirmed_by_whom: 'n/a').save

    pp = PlantPart.new(plant_part: 'average of blocks',
                       description: 'average of blocks',
                       described_by_whom: 'pierre.carion@bbsrc.ac.uk',
                       comments: 'no comment',
                       entered_by_whom: 'pierre.carion@bbsrc.ac.uk',
                       date_entered: '2015-03-21',
                       data_provenance: 'n/a',
                       confirmed_by_whom: 'n/a').save

    pp = PlantPart.new(plant_part: 'average of trays',
                       description: 'average of trays',
                       described_by_whom: 'pierre.carion@bbsrc.ac.uk',
                       comments: 'no comment',
                       entered_by_whom: 'pierre.carion@bbsrc.ac.uk',
                       date_entered: '2015-03-21',
                       data_provenance: 'n/a',
                       confirmed_by_whom: 'n/a').save

  end
end
