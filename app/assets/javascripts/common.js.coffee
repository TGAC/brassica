$ ->
  $('.data-table').DataTable
    lengthMenu: [[10, 25, 100, -1], [10, 25, 100, "All"]]
    pageLength: 25
    processing: true
    # NOTE: use server side processing for large data (too heavy for clients)
    # serverSide: true
