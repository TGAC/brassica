window.Submission = class Submission extends Component
  @makeAjaxSelectOptions: (url, id_attr, text_attr, small_text_attr) =>
    text_attr ||= id_attr

    allowClear: true
    minimumInputLength: 2
    ajax:
      url: url
      dataType: 'json'
      data: (params) ->
        search = {}
        search[text_attr] = params.term

        search: search
        page: params.page
      processResults: (data, params) ->
        results: $.map(data.results, (row) -> { id: row[id_attr], text: row[text_attr], small_text: row[small_text_attr] })
        pagination:
          more: data.page * data.per_page < data.total_count
    escapeMarkup: (markup) -> markup
    templateResult: (item) ->
      result = item.text
      result += "<br/><small>#{item.small_text}</small>" if item.small_text
      result
    templateSelection: (item) -> item.text

  @makeAjaxListSelectOptions: (url, id_attr, text_attr, small_text_attr) =>
    $.extend(@makeAjaxSelectOptions(url, id_attr, text_attr, small_text_attr),
      multiple: true
      templateSelection: (item) ->
        if item.id != item.text || ! item.selected
          "<span class='existing-item-for-list-selection'>#{item.text}</span>"
        else
          "<span class='new-item-for-list-selection'>#{item.text}</span>"
    )

  init: =>
    return unless @$el.length >= 1
    @initDirtyTracker()

  initDirtyTracker: =>
    @dirtyTracker = new DirtyTracker(@$el[0]).init()

    $('input[type=submit][name=back], button[type=submit][name=back], .step a').on 'click', (event) =>
      if @dirtyTracker.isChanged()
        msg = "Discard unsaved changes?"

        target_step = $(event.target).attr("data-step-to")
        current_step = @$('form').attr("data-step")

        if Number(target_step) > Number(current_step)
          msg += "\nIf you want to save your changes click the 'Next' button " +
                 "below the form.\n"

        unless confirm(msg)
          event.preventDefault()
          event.stopPropagation()
