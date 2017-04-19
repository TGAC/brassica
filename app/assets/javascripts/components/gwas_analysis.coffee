window.GwasAnalysis = class GwasAnalysis extends Component
  init: =>
    return unless @$el.length >= 1

    this.bindGenotypeUpload()
    this.bindMapUpload()
    this.bindPhenotypeUpload()

  bindGenotypeUpload: =>
    $map_form_group = this.$('.map-data-file-fileinput').parents('.form-group')
    $map_fileinput = $map_form_group.find('.fileinput')
    $map_upload_result = @$("div.map-data-file")

    this.bindDataFile('genotype-data-file',
      done: (data) =>
        if data.result.file_file_name.match(/\.vcf$/)
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
    this.bindDataFile('phenotype-data-file')

  bindDataFile: (field, options = {}) =>
    $fileinput = @$(".#{field}-fileinput")
    $result = @$("div.#{field}")

    @$("input.#{field}").fileupload
      data_type: 'json'

      add: (event, data) =>
        $fileinput.find('.fileinput-button').addClass('disabled')
        data.submit()

      done: (event, data) =>
        $(".errors").addClass('hidden').text("")

        @$("#analysis_#{field.replace(/-/g, '_')}_id").val(data.result.id)

        $fileinput.addClass('hidden')
        $fileinput.find('.fileinput-button').removeClass('disabled')

        $result.removeClass('hidden')
        $result.find('.file-name').text(data.result.file_file_name)
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

    @$(".delete-#{field}").on 'ajax:success', (data, status, xhr) =>
      $fileinput.removeClass('hidden')
      $result.addClass('hidden')

      options.delete && options.delete()

