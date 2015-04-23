class DropScoringOccasions < ActiveRecord::Migration
  def up
    # Fix missing ts->so links
    scoring_links = {
    'occ_HRI_UN0000_003': '12',
    'occ.RRES_JB0410_002': '8',
    'occ.WHRI_MB0000_002': '16',
    'occ.RRES_JB0310_001': '5',
    'occ.RRES_JB0410_001': '7',
    'occ.WHRI_MB0000_001': '10',
    'occ_PRT7_UN0000_001': '14',
    'occ.WHRI_MB0000_003': '18',
    'occ_PRT7_UN0000_002': '15',
    'occ.WHRI_MB0000_004': '19',
    'occ_HRI_UN0000_001': '9',
    'occ_HRI_UN0000_002': '11',
    'occ_HRI_UN0000_004': '13',
    'occ.RRES_JB0310_002': '6',
    'occ_PRT7_UN0000_003': '17'}

    scoring_links.each do |k,v|
      execute "UPDATE trait_scores SET scoring_occasion_id = #{v} WHERE scoring_occasion_name = '#{k}'"
    end

    unless column_exists?(:trait_scores, :scoring_date)
      execute "ALTER TABLE trait_scores ADD COLUMN scoring_date DATE"
      tss = execute("SELECT id, scoring_occasion_id FROM trait_scores")
      tss.each do |ts|
        unless ts['scoring_occasion_id'].blank?
          sodate = execute("SELECT score_start_date FROM scoring_occasions WHERE id = #{ts['scoring_occasion_id']}")
          if sodate.ntuples > 0 and !(sodate.first['score_start_date'].blank?)
            execute "UPDATE trait_scores SET scoring_date = '#{sodate.first['score_start_date'].to_s}' WHERE id = #{ts['id']}"
          end
        end
      end
      execute "DROP TABLE scoring_occasions"
      execute "ALTER TABLE trait_scores DROP COLUMN scoring_occasion_name"
    end
  end

  def down
  end

end