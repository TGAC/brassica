$ ->
  # Default settings for ALL DataTables
  $.extend $.fn.dataTable.defaults,
    lengthMenu: [[10, 25, 100, -1], [10, 25, 100, 'All']]
    pageLength: 25
    processing: true
    stateSave: true
    deferRender: true
#    dom: "<'row'<'col-sm-3'f><'col-sm-6'T><'col-sm-3'l>><'row'<'col-sm-12'tr>><'row'<'col-sm-6'i><'col-sm-6'p>>"
    dom: "<'table-bar'<'col-sm-3 form-group'f><'col-sm-7 form-group'T><'col-sm-2 form-group'l>><'row'<'col-sm-12 'tr>><'row table-footer'<'col-sm-6'i><'col-sm-6'p>>"
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
        sButtonClass: 'btn-sm'
        sButtonText: 'Back'
        fnClick: ( nButton, oConfig, oFlash ) ->
          window.location = $('#table-back-button').attr('href')
        fnInit: ( nButton, oConfig ) ->
          if $('#table-back-button').length
            $(nButton).find('span').html($('#table-back-button').data('label'))
          else
            $(nButton).hide()
      ,
        sExtends: 'text'
        sButtonClass: 'btn-sm'
        sButtonText: 'See all records'
        fnClick: ( nButton, oConfig, oFlash ) ->
          window.location = $('#table-see-all-button').attr('href')
        fnInit: ( nButton, oConfig ) ->
          if $('#table-see-all-button').length
            $(nButton).find('span').html($('#table-see-all-button').data('label'))
          else
            $(nButton).hide()
      ,
        sExtends: 'text'
        sButtonClass: 'btn-sm'
        sButtonText: '<i class="fa fa-download"></i> Export to CSV'
        sToolTip: 'Generates a CSV file with the content of the table below.'
        sFieldSeperator: ','
        oSelectorOpts:
          search: 'applied'
        sFieldBoundary: '"'
        mColumns: (dt) ->
          api = new $.fn.dataTable.Api(dt)
          api.columns().indexes().toArray().slice(0, -2)
        fnClick: ( nButton, oConfig, oFlash ) ->
          data = this.fnGetTableData(oConfig)
          blob = new Blob([data])
          filename = 'BIP_' + $(this.s.dt.nTable).attr('id').replace(/-/g,'_') + '.csv'
          if window.navigator.msSaveOrOpenBlob
            window.navigator.msSaveBlob(blob, filename)
          else
            a = window.document.createElement("a")
            a.href = window.URL.createObjectURL(blob, {type: "text/plain"})
            a.download = filename
            document.body.appendChild(a)
            a.click()
            document.body.removeChild(a)
      ]


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
      'Annotations' +
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
          content += pubmedLink(response['pubmed_id'])
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

window.pubmedLink = (value) ->
  if value
    "<a href='http://www.ncbi.nlm.nih.gov/pubmed/#{escapeHtml(value)}' target='_blank'>PubMed Link</a></br>"
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
