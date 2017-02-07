window.GwasAnalysis = class GwasAnalysis extends Component
  constructor: (el) ->
    @$el = $(el)

  $: (args) =>
    @$el.find(args)

  init: =>
    return unless @$el.length >= 1

    @bindDataFile('genotype-data-file')
    @bindDataFile('phenotype-data-file')

  bindDataFile: (field) =>
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

