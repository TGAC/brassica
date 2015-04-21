$ ->
  searchSelectOptions =
    allowClear: true
    minimumInputLength: 2
    ajax:
      url: "/searches/new"
      dataType: 'json'
      data: (params) ->
        $('.search').data(term: params.term)

        search: params.term
        page: params.page
      processResults: (data, page) ->
        results: $.map(data, (row) -> { id: row.model, text: row.message })
    escapeMarkup: (markup) -> markup
    templateResult: (item) -> item.text
    templateSelection: (item) -> item.text

  $('.search').select2(searchSelectOptions).on('select2:select', (event) =>
    model = event.params.data.id
    term = $('.search').data().term
    window.location = "/data_tables?model=#{model}&search=#{term}"
  )

