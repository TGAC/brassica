class MergeOccasions < ActiveRecord::Migration
  def up
    ocs = execute('SELECT * FROM occasions')
    scocs = ScoringOccasion.all
    scoc_keys = scocs.collect { |scoc| scoc.scoring_occasion_name }
    ocs.each do |oc|
      # Check if this record already exists in scoring_occasions
      if scoc_keys.include? oc['occasion_id']
        # Do nothing
        puts "Occasion #{oc['occasion_id']} already present in scoring_occasions."
      else
        sd = oc['start_date'].blank? ? 'NULL' : "'#{oc['start_date'].to_s}'"
        ed = oc['end_date'].blank? ? 'NULL' : "'#{oc['end_date'].to_s}'"
        entd = oc['date_entered'].blank? ? 'NULL' : "'#{oc['date_entered'].to_s}'"

        insert = "INSERT INTO scoring_occasions(scoring_occasion_name, score_start_date, \
                  score_end_date, comments, entered_by_whom, date_entered, data_provenance, \
                  data_owned_by) VALUES ( \
                  '#{oc['occasion_id']}',
                  #{sd}, \
                  #{ed}, \
                  '#{oc['comments']}', \
                  '#{oc['entered_by_whom']}', \
                  #{entd}, \
                  '#{oc['data_provenance']}', \
                  '#{oc['data_owned_by']}')"
        execute insert
      end
    end
    execute ("DROP TABLE occasions")
  end

  def down
  end

end
