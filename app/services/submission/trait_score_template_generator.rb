class Submission::TraitScoreTemplateGenerator
  def initialize(submission)
    raise ArgumentError, "Required plant trial submission" unless submission.trial?
    @submission = submission
  end

  def call(&blk)
    generate_xls_file

    File.open(filename, "r", &blk)
    FileUtils.rm_rf(filename)
  end

  private

  def generate_xls_file
    workbook = WriteExcel.new(filename)
    worksheet = workbook.add_worksheet("Trait scores")
    worksheet.protect

    formats = add_formats(workbook)

    add_headers_and_descriptions(worksheet, formats)
    add_placeholder_data(worksheet)

    workbook.close
  end

  def filename
    @filename ||= File.join(Dir.tmpdir, Dir::Tmpname.make_tmpname(["plant-trial-scoring", ".xls"], nil))
  end

  def add_headers_and_descriptions(worksheet, formats)
    worksheet.set_row(0, 25)
    worksheet.set_row(1, 55)

    worksheet.set_column(0, headers.size, 25, formats.data)
    worksheet.set_column(0, 0, 15, formats.first_col)

    worksheet.write(0, 0, "Column", formats.first_col_header)
    worksheet.write(1, 0, "Description", formats.first_col_header)

    scoring_unit_offset = 0
    design_factors_offset = 1
    plant_accession_offset = design_factors_offset + design_factor_names.size
    line_or_variety_offset = plant_accession_offset + 3
    traits_offset = line_or_variety_offset + 1

    worksheet.write(0, 1 + scoring_unit_offset, headers[scoring_unit_offset], formats.col_header)
    worksheet.write(1, 1 + scoring_unit_offset, descriptions[scoring_unit_offset], formats.col_description)

    headers[design_factors_offset, design_factor_names.size].each.with_index do |header, idx|
      worksheet.write(0, 1 + design_factors_offset + idx, header, formats.design_factor_col_header)
      worksheet.write(1, 1 + design_factors_offset + idx, descriptions[design_factors_offset + idx],
                      formats.design_factor_col_description)
    end

    headers[plant_accession_offset, 3].each.with_index do |header, idx|
      worksheet.write(0, 1 + plant_accession_offset + idx, header, formats.plant_accession_col_header)
      worksheet.write(1, 1 + plant_accession_offset + idx, descriptions[plant_accession_offset + idx],
                      formats.plant_accession_col_description)
    end

    worksheet.write(0, 1 + line_or_variety_offset, headers[line_or_variety_offset], formats.col_header)
    worksheet.write(1, 1 + line_or_variety_offset, descriptions[line_or_variety_offset], formats.col_description)

    headers[traits_offset, traits.size].each.with_index do |header, idx|
      worksheet.write(0, 1 + traits_offset + idx, header, formats.trait_col_header)
      worksheet.write(1, 1 + traits_offset + idx, descriptions[traits_offset + idx], formats.trait_col_description)
    end
  end

  def add_placeholder_data(worksheet)
    ['A','B'].each.with_index do |sample, sample_idx|
      sample_values = traits.map { |trait| "Value of #{trait} scored for sample #{sample} - replace_it" }

      values =
        ["Sample scoring unit #{sample} name - replace it"] +
        design_factors[sample] +
        ['Accession identifier - replace it',
         'Organisation name or acronym - replace it',
         'Year produced - replace it',
         "Plant #{line_or_variety} name - replace it"] +
        sample_values

      values.each.with_index do |value, idx|
        worksheet.write(2 + sample_idx, 1 + idx, value)
      end
    end
  end

  def headers
    ['Plant scoring unit name'] + design_factor_names +
      ['Plant accession', 'Originating organisation', "Year produced", "Plant #{line_or_variety}"] + traits
  end

  def descriptions
    ["Unique plant scoring unit identifier."] +
      (["Design factor identifier"] * design_factor_names.size) +
      ["Accession identifier.", "The organisation which named the accession.", "Year the accession was produced."] +
      ["Name of a plant line already registered in BIP."] +
      traits.map { |trait| "Value of #{trait}." }
  end

  def add_formats(workbook)
    workbook.set_custom_color(9, 255, 153, 153) # pinkish
    workbook.set_custom_color(10, 204, 153, 0) # brown
    workbook.set_custom_color(11, 255, 211, 81) # light brown
    workbook.set_custom_color(12, 255, 102, 255) # fuchsia
    workbook.set_custom_color(13, 252, 202, 253) # light fuchsia
    workbook.set_custom_color(14, 102, 204, 0) # green
    workbook.set_custom_color(15, 204, 255, 102) # light green
    workbook.set_custom_color(16, 0, 204, 204) # blue
    workbook.set_custom_color(17, 153, 255, 255) # light blue

    first_col = workbook.add_format(locked: 1).tap do |format|
      format.set_bg_color(9)
      format.set_align('center')
      format.set_align('top')
    end

    OpenStruct.new(
      data: workbook.add_format(locked: 0, num_format: 49), # 49 - text format, i.e. '@'
      first_col_header: add_header_format(workbook).tap { |format| format.set_bg_color(9) },
      first_col: first_col,
      col_header: add_header_format(workbook),
      col_description: add_description_format(workbook),
      design_factor_col_header: add_header_format(workbook).tap { |format| format.set_bg_color(10) },
      design_factor_col_description: add_description_format(workbook).tap { |format| format.set_bg_color(11) },
      plant_accession_col_header: add_header_format(workbook).tap { |format| format.set_bg_color(12) },
      plant_accession_col_description: add_description_format(workbook).tap { |format| format.set_bg_color(13) },
      trait_col_header: add_header_format(workbook).tap { |format| format.set_bg_color(16) },
      trait_col_description: add_description_format(workbook).tap { |format| format.set_bg_color(17) }
    )
  end

  def add_header_format(workbook)
    workbook.add_format(locked: 1).tap do |format|
      format.set_bold
      format.set_bg_color(14)
      format.set_border(1)
      format.set_text_wrap(1)
      format.set_align('center')
      format.set_align('vcenter')
    end
  end

  def add_description_format(workbook)
    workbook.add_format(locked: 1).tap do |format|
      format.set_bg_color(15)
      format.set_border(1)
      format.set_text_wrap(1)
      format.set_align('top')
    end
  end

  def line_or_variety
    @submission.content.lines_or_varieties == 'plant_varieties' ? 'variety' : 'line'
  end

  def trait_names
    @trait_names ||= PlantTrialSubmissionDecorator.decorate(@submission).sorted_trait_names
  end

  def traits
    return @traits if defined?(@traits)

    technical_replicate_numbers = @submission.content.technical_replicate_numbers || {}
    @traits = trait_names.map.with_index do |trait_name, idx|
      if technical_replicate_numbers[idx] && technical_replicate_numbers[idx].to_i > 1
        reps_count = [technical_replicate_numbers[idx].to_i, 2].max
        reps_count.times.map { |rep| "#{trait_name} rep#{rep + 1}" }
      else
        trait_name
      end
    end.flatten
  end

  def design_factor_names
    @design_factor_names ||= @submission.content.design_factor_names || []
  end

  def design_factors
    design_factors = {
      'A' => design_factor_names.map { '1 - replace it' },
      'B' => design_factor_names.map { '1 - replace it' }
    }
    design_factors['B'][-1] = '2 - replace it' if design_factors['B'].present?
    design_factors
  end
end
