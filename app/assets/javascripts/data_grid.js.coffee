$ ->
  # Default settings for ALL DataTables
  $.extend $.fn.dataTable.defaults,
    lengthMenu: [[10, 25, 100, -1], [10, 25, 100, 'All']]
    pageLength: 25
    processing: true
    stateSave: true
    dom: "<'row'<'col-sm-4'l><'col-sm-4'T><'col-sm-4'f>><'row'<'col-sm-12'tr>><'row'<'col-sm-6'i><'col-sm-6'p>>"
    drawCallback: (settings) ->
      # This removes the pagination control when only 1 page
      # and the page length picker when less data than the minimum value
      api = this.api()
      paginate = $(api.table().container()).find('.dataTables_paginate')
      lengthPicker = $(api.table().container()).find('.dataTables_length')
      if api.page.info()['pages'] < 2
        paginate.hide()
      else
        paginate.show()
      if api.page.info()['recordsDisplay'] < 11
        lengthPicker.hide()
      else
        lengthPicker.show()
    # NOTE: use server side processing for large data (too heavy for clients)
    # serverSide: true

  $.extend $.fn.dataTable.TableTools.defaults,
    aButtons:
      [
        sExtends: 'text'
        sButtonText: 'Back'
        fnClick: ( nButton, oConfig, oFlash ) ->
          window.location = $('#table-back-button').attr('href')
        fnInit: ( nButton, oConfig ) ->
          if $('#table-back-button').length
            $(nButton).find('span').html($('#table-back-button').data('label'))
          else
            $(nButton).hide()
      ,
        sExtends: 'csv'
        sButtonText: 'Export to CSV'
        sFileName: '*.csv'
        sToolTip: 'Generates a CSV file with the content of the table below.'
        oSelectorOpts:
          filter: 'applied'
      ]
    sSwfPath: '/swf/copy_csv_xls.swf'


  $('.data-table').each (i)->
    specificConfig = window.configs[this.id]
    if specificConfig
      specificConfig['columnDefs'] =
        $.merge(specificConfig['columnDefs'], window.baseColumnDefs(this.id))
    else
      specificConfig =
        columnDefs: window.baseColumnDefs(this.id)
    $(this).DataTable specificConfig


  $('body').popover
    selector: '[data-popover-source]'
    placement: 'left'
    trigger: 'focus'
    html: 'true'
    title: ->
      $('body').on 'click', '.metadata-close', =>
        $(this).data('bs.popover').hide()
      $(this).data('title') +
      '<button type="button" class="close metadata-close" aria-label="Close">' +
        '<span aria-hidden="true">&times;</span>' +
      '</button>'
    content: ->
      $.ajax
        url: $(this).data('popover-source')
        success: (response) =>
          content = ''
          content += metadataElement('Data owner', response['data_owned_by'])
          content += metadataElement('Provenance', response['data_provenance'])
          content += metadataElement('Comments', response['comments'])
          content += metadataElement('Entered by', response['entered_by_whom'])
          content += metadataElement('Entry date', response['date_entered'])
          content = 'No annotations' if content == ''
          $(this).data('bs.popover').options.content = content
          # This is required for the popover to reposition itself properly
          $(this).data('bs.popover').show()
      '<i>Loading...</i>'

window.metadataElement = (title, value) ->
  if value
    "<strong>#{title}</strong>: #{escapeHtml(value)}</br>"
  else
    ''

window.escapeHtml = (string) ->
  entityMap = {
    "&": "&amp;"
    "<": "&lt;"
    ">": "&gt;"
    '"': '&quot;'
    "'": '&#39;'
    "/": '&#x2F;'
  }
  String(string).replace /[&<>"'\/]/g, (s) ->
    entityMap[s]


window.baseColumnDefs = (model) ->
  [
    targets: 'pubmed'
    render: (data, type, full, meta) ->
      objectId = full[full.length - 2]
      if objectId
        '<a class="btn btn-xs btn-info" href="http://www.ncbi.nlm.nih.gov/pubmed/' + objectId + '">PubMed link</a>'
      else
        ''
  ,
    targets: 'annotations'
    render: (data, type, full, meta) ->
      objectId = full[full.length - 1]
      if objectId
        '<button class="btn btn-xs btn-info" data-title="Metadata" data-popover-source="data_tables/' + objectId + '?model=' + model + '">Metadata link</button>'
      else
        ''
  ]


# Specific configurations for particular DataTables, including callbacks
window.configs =
  'plant-lines':
    columnDefs:
      [
        targets: 'name_column'
        render: (data, type, full, meta) ->
          data.replace(/Brassica/, 'B.')
      ,
        targets: 'plant_variety_name_column'
        render: (data, type, full, meta) ->
          if data && full[8]
            '<a href="data_tables?model=plant_varieties&query[id]=' + full[8] + '">' + data + '</a>'
          else
            data
      ]

  'trait-descriptors':
    columnDefs:
      [
        targets: 'project_descriptor_column'
        render: (data, type, full, meta) ->
          if data
            '<a href="data_tables?model=plant_trials&query[project_descriptor]=' + data + '">' + data + '</a>'
          else
            ''
      ,
        targets: 'trait_scores_count_column'
        render: (data, type, full, meta) ->
          if data && full[2]
            '<a href="data_tables?model=trait_scores&query[trait_descriptors.descriptor_name]=' + full[2] + '">' + data + '</a>'
          else
            ''
      ]

  'plant-populations':
    columnDefs:
      [
        targets: 'name_column'
        render: (data, type, full, meta) ->
          data.replace(/Brassica/, 'B.')
      ,
        targets: 'female_parent_line_column'
        render: (data, type, full, meta) ->
          if data && full[7]
            '<a href="data_tables?model=plant_lines&query[id]=' + full[7] + '">' + data + '</a>'
          else
            ''
      ,
        targets: 'male_parent_line_column'
        render: (data, type, full, meta) ->
          if data && full[8]
            '<a href="data_tables?model=plant_lines&query[id]=' + full[8] + '">' + data + '</a>'
          else
            ''
      ,
        targets: 'plant_population_lists_count_column'
        render: (data, type, full, meta) ->
          if data && data != '0' && full[9]
            '<a href="data_tables?model=plant_lines&query[plant_populations.id]=' + full[9] + '">' + data + '</a>'
          else
            ''
      ]
