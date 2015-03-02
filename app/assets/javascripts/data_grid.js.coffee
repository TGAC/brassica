$ ->
  # Default settings for ALL DataTables
  $.extend $.fn.dataTable.defaults,
    lengthMenu: [[10, 25, 100, -1], [10, 25, 100, 'All']]
    pageLength: 25
    processing: true
    # NOTE: use server side processing for large data (too heavy for clients)
    # serverSide: true

  $('.data-table').each (i)->
    $(this).DataTable window.configs[this.id]


# Specific configurations for particular DataTables, including callbacks
window.configs =
  'plant-lines':
    paging: false
    columnDefs:
      [
        targets: 1
        render: (data, type, full, meta) ->
          data.replace(/Brassica/, 'B.')
      ]

  'plant-populations':
    columnDefs:
      [
        targets: [2, 3]
        render: (data, type, full, meta) ->
          if data
            '<a href="plant_lines?plant_line_names[]=' + data + '">' + data + '</a>'
          else
            ''
      ]
