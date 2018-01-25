class Submission::PlantTrialEnvironmentParser
  def self.environment_labels
    {
      day_temperature: "Average day temperature",
      night_temperature: "Average night temperature",
      temperature_change: "Change over the course of experiment",
      ppfd_plant: "Average daily integrated photosynthetic photon flux density (PPFD) measured at plant level",
      ppfd_canopy: "Average daily integrated photosynthetic photon flux density (PPFD) measured at canopy level",
      light_period: "Average length of the light period",
      light_intensity: "Light intensity",
      light_intensity_range: "Range in peak light intensity",
      outside_light_loss: "Fraction of outside light intercepted by growth facility components and surrounding structures",
      lamps: "Type of lamps used",
      rfr_ratio: "R/FR ratio",
      daily_uvb: "Daily UV-B radiation",
      total_light: "Total daily irradiance",
      co2_controlled: "Atmospheric CO2 concentration",
      co2_light: "Average CO2 during the light periods",
      co2_dark: "Average CO2 during the dark periods",
      relative_humidity_light: "Average relative humidity during the light period",
      relative_humidity_dark: "Average relative humidity during the dark period",
      rooting_media: "Rooting medium",
      containers: "Container type",
      rooting_container_volume: "Container volume",
      rooting_container_type: "Container height",
      rooting_count: "Number of plants per container",
      sowing_density: "Sowing density",
      # TODO:
      # "pH",
      medium_temperature: "Medium temperature",
      soil_porosity: "Porosity",
      soil_penetration: "Soil penetration stength",
      soil_organic_matter: "Organic matter content",
      water_retention: "Water retention capacity",
      nitrogen_content: "Extractable N content per unit ground area before fertiliser added",
      nitrogen_concentration_start: "Concentration of Nitrogen before start of the experiment",
      nitrogen_concentration_end: "Extractable N content per unit ground area at the end of the experiment",
      conductivity: "Electrical conductivity",
      topological_descriptors: "Plot topology"
    }
  end

  def call(filename)
    xls = Roo::Excel.new(filename)

    errors = check_errors(xls)
    environment = errors.empty? ? parse_sheet(xls, "Environment", self.class.environment_labels) : {}

    Result.new(errors, environment)
  end

  private

  def check_errors(xls)
    return [:no_environment_sheet] unless xls.sheets.include?("Environment")
    return [:too_few_rows_in_environment_sheet] if xls.last_row("Environment").to_i < 4

    [].tap do |errors|
      unless  xls.row(1, "Environment")[0...environment_sheet_headers.size] == environment_sheet_headers
        errors << :invalid_environment_sheet_headers
      end
    end
  end

  def environment_sheet_headers
    ["Attribute", nil, "Unit (or Term)"]
  end

  def parse_sheet(xls, sheet, labels)
    xls.default_sheet = sheet

    ids = labels.dup.transform_values { |label| label_id(label) }
    data = (1..xls.last_row).
      map { |row_idx| [row_idx, xls.cell(row_idx, 1)] }.
      select { |row_idx, label| label && ids.value?(label_id(label)) }.
      map { |row_idx, _| parse_row(xls, row_idx) }.
      select { |label, values| values.present? }.
      map { |label, values| [ids.key(label_id(label)), [label.gsub(/\s+/, " "), values]] }

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
    attr_reader :errors, :environment

    def initialize(errors, environment)
      @errors = errors || []
      @environment = environment || []
    end

    def valid?
      errors.empty?
    end
  end
end
