window.GwasAnalysis = class GwasAnalysis extends Component
  init: =>
    return unless @$el.length >= 1

    this.bind()

  bind: =>
    this.bindPlantTrialSelect()
    this.bindGenotypeUpload()
    this.bindMapUpload()
    this.bindPhenotypeUpload()

  bindPlantTrialSelect: =>
    $select = this.$("#analysis_plant_trial_id")
    $select.on "change", (event) =>
      this.clearDataFile("phenotype-data-file")
      this.updateGenotypeTemplateLink($select.val())

  bindGenotypeUpload: =>
    $map_form_group = this.$('.map-data-file-fileinput').parents('.form-group')
    $map_fileinput = $map_form_group.find('.fileinput')
    $map_upload_result = this.$("div.map-data-file")

    this.bindDataFile('genotype-data-file',
      done: (data) =>
        if data.result.file_format == "vcf" || data.result.file_format == "hapmap"
          $map_form_group.addClass('hidden')
        else
          $map_form_group.removeClass('hidden')

      delete: =>
        $map_form_group.addClass('hidden')
        $map_fileinput.removeClass('hidden')
        $map_upload_result.addClass('hidden')

        this.$("#analysis_map_data_file_id").val("")
    )

  bindMapUpload: =>
    this.bindDataFile('map-data-file')

  bindPhenotypeUpload: =>
    this.bindDataFile('phenotype-data-file',
      done: (data) =>
        $select = this.$("#analysis_plant_trial_id")
        $select.val("")
        this.updateGenotypeTemplateLink($select.val())
    )

  bindDataFile: (field, options = {}) =>
    $fileinput = this.$(".#{field}-fileinput")
    $result = this.$("div.#{field}")

    this.$("input.#{field}").fileupload
      dataType: 'json'
      dropZone: $fileinput

      add: (event, data) =>
        $fileinput.find('.fileinput-button').addClass('disabled')
        data.submit()

      done: (event, data) =>
        $(".errors").addClass('hidden').text("")

        this.$("#analysis_#{field.replace(/-/g, '_')}_id").val(data.result.id)

        $fileinput.addClass('hidden')
        $fileinput.find('.fileinput-button').removeClass('disabled')

        $result.removeClass('hidden')
        $result.find('.file-name').text(data.result.file_file_name)
        $result.find('.file-format').text(data.result.file_format_name)
        $result.find(".delete-#{field}").attr(href: data.result.delete_url)

        options.done && options.done(data)

      fail: (event, data) =>

        if data.jqXHR.status == 401
          window.location.reload()
        else if data.jqXHR.status == 422
          $fileinput.find('.fileinput-button').removeClass('disabled')

          $errors = $(".#{field}-errors").text("").removeClass('hidden').append("<ul></ul>")
          $.each(data.jqXHR.responseJSON.errors, (_, error) =>
            $li = $("<li></li>").text(error)
            $errors.find("ul").append($li)
          )
        else
          $fileinput.find('.fileinput-button').removeClass('disabled')

          $errors = $(".#{field}-errors").text("").removeClass('hidden').append("<ul></ul>")
          $errors.find("ul").append($("<li></li>").text("Unexpected server response: #{data.jqXHR.status} #{data.jqXHR.statusText}"))

    this.$(".delete-#{field}").on 'ajax:success', (data, status, xhr) =>
      $fileinput.removeClass('hidden')
      $result.addClass('hidden')

      options.delete && options.delete()

  clearDataFile: (field) =>
    $fileinput = this.$(".#{field}-fileinput")
    $result = this.$("div.#{field}")

    $fileinput.removeClass('hidden')
    $result.addClass('hidden')

    this.$("#analysis_#{field.replace(/-/g, '_')}_id").val("")

  updateGenotypeTemplateLink: (plant_trial_id) =>
    $link = this.$("#analysis_gwas_genotype_template_download")

    url = $link.attr("href")
    params = Url.queryParams(url)
    params["plant_trial_id"] = plant_trial_id
    url = Url.replaceQueryParams(url, params)

    $link.attr(href: url)
