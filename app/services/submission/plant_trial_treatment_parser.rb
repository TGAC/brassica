class Submission::PlantTrialTreatmentParser
  def self.treatment_labels
    {
      air_applications: "Air treatment regime",
      season_applications: "Seasonal environment",
      soil_applications: "Soil treatment regime",
      soil_temperature_applications: "Soil temperature regime",
      antibiotic_applications: "Antibiotic regime",
      chemical_applications: "Chemical administration",
      biotic_applications: "Biotic treatment",
      fertilizer_applications: "Fertilizer regime",
      fungicide_applications: "Fungicide regime",
      gas_applications: "Gaseous regime",
      gravity_applications: "Gravity",
      hormone_applications: "Growth hormone regime",
      herbicide_applications: "Herbicide regime",
      mechanical_applications: "Mechanical treatment",
      humidity_applications: "Humidity regimen",
      radiation_applications: "Radiation regime",
      rainfall_applications: "Rainfall regime",
      salt_applications: "Salt regime",
      water_temperature_applications: "Water temperature regime",
      watering_applications: "Watering regime",
      pesticide_applications: "Pesticide regime",
      ph_applications: "pH regime"
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
