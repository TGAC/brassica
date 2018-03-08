module Analyses
  module Gapit
    class Form < Analyses::Gwasser::Form
      validates :map_data_file, presence: true, if: :genotype_csv_based?
    end
  end
end
