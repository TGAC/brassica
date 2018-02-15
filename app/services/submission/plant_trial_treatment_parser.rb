class Submission::PlantTrialTreatmentParser
  def self.treatment_labels
    {
      air: "Air treatment regime",
      season: "Seasonal environment",
      soil: "Soil treatment regime",
      soil_temperature: "Soil temperature regime",
      antibiotic: "Antibiotic regime",
      chemical: "Chemical administration",
      biotic: "Biotic treatment",
      fertilizer: "Fertilizer regime",
      fungicide: "Fungicide regime",
      gas: "Gaseous regime",
      gravity: "Gravity",
      hormone: "Growth hormone regime",
      herbicide: "Herbicide regime",
      mechanical: "Mechanical treatment",
      humidity: "Humidity regimen",
      radiation: "Radiation regime",
      rainfall: "Rainfall regime",
      salt: "Salt regime",
      water_temperature: "Water temperature regime",
      watering: "Watering regime",
      pesticide: "Pesticide regime",
      ph: "pH regime"
    }
  end

  def call(filename)
    xls = Roo::Excel.new(filename)

    errors = check_errors(xls)
    treatment = errors.empty? ? parse_sheet(xls, "Treatment", self.class.treatment_labels) : {}

    Result.new(errors, treatment)
  end

  private

  def check_errors(xls)
    return [:no_treatment_sheet] unless xls.sheets.include?("Treatment")
    return [:too_few_rows_in_treatment_sheet] if xls.last_row("Treatment").to_i < 4

    [].tap do |errors|
      unless  xls.row(1, "Treatment")[0...treatment_sheet_headers.size] == treatment_sheet_headers
        errors << :invalid_treatment_sheet_headers
      end
    end
  end

  def treatment_sheet_headers
    ["Treatment", nil, "Type of first treatment", "Type of second treatment", "Type of third treatment"]
  end

  def parse_sheet(xls, sheet, labels)
    xls.default_sheet = sheet

    ids = labels.dup.transform_values { |label| label_id(label) }
    data = (1..xls.last_row).
      map { |row_idx| [row_idx, xls.cell(row_idx, 1)] }.
      select { |row_idx, label| label && ids.value?(label_id(label)) }.
      map { |row_idx, _| parse_row(xls, row_idx) }.
      select { |label, values| values.present? }.
      map { |label, values| [ids.key(label_id(label)), [label, values]] }

    Hash[data]
  end

  def parse_row(xls, row_idx)
    label = xls.cell(row_idx, 1)
    data = (3..xls.last_column).
      map { |col_idx| [xls.cell(row_idx, col_idx), xls.cell(row_idx + 1, col_idx)] }.
      select { |values| values.any?(&:present?) }

    [label, data]
  end

  def label_id(label)
    label.split(/\s+/).join("-").underscore
  end

  class Result
    attr_reader :errors, :treatment

    def initialize(errors, treatment)
      @errors = errors || []
      @treatment = treatment || []
    end

    def valid?
      errors.empty?
    end
  end
end
