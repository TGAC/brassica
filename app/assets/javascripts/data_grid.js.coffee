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
        sExtends: 'csv'
        sButtonText: 'Export to CSV'
        sFileName: '*.csv'
        sToolTip: 'Generates a CSV file with the content of the table below.'
        oSelectorOpts:
          filter: 'applied'
      ]
    sSwfPath: '/swf/copy_csv_xls.swf'


  $('.data-table').each (i)->
    $(this).DataTable window.configs[this.id]


# Specific configurations for particular DataTables, including callbacks
window.configs =
  'plant-lines':
    columnDefs:
      [
        targets: 1
        render: (data, type, full, meta) ->
          data.replace(/Brassica/, 'B.')
      ]

  'trait-descriptors':
    columnDefs:
      [
        targets: [3]
        render: (data, type, full, meta) ->
          if data
            '<a href="data_tables?model=plant_trials&query[project_descriptor]=' + data + '">' + data + '</a>'
          else
            ''
      ]

  'plant-populations':
    columnDefs:
      [
        targets: [3, 4]
        render: (data, type, full, meta) ->
          if data
            '<a href="data_tables?model=plant_lines&query[plant_line_name][]=' + data + '">' + data + '</a>'
          else
            ''
      ,
        targets: [6]
        render: (data, type, full, meta) ->
          if data && data != '0'
            '<a href="data_tables?model=plant_lines&query[plant_populations.plant_population_id]=' + full[0] + '">' + data + '</a>'
          else
            ''
      ]
