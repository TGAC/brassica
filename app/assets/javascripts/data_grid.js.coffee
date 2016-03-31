$ ->
  # Default settings for ALL DataTables
  $.extend $.fn.dataTable.defaults,
    lengthMenu: [[10, 25, 100, -1], [10, 25, 100, 'All']]
    pageLength: 25
    processing: true
    stateSave: true
    stateLoadParams: (settings, data) ->
      data.search.search = ''
    deferRender: true
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
        sExtends: if window.isSafari() then 'csv' else 'text'
        sButtonClass: 'btn-sm'
        sButtonText: '<i class="fa fa-download"></i> Export to CSV'
        sFileName: '*.csv'
        sFieldSeperator: ','
        oSelectorOpts:
          search: 'applied'
        sFieldBoundary: '"'
        mColumns: (dt) ->
          api = new $.fn.dataTable.Api(dt)
          if $(dt.nTHead).find('th.related').length
            api.columns().indexes().toArray().slice(0, -2)
          else if dt.sInstance == 'trial-scoring'
            api.columns().indexes().toArray()
          else
            api.columns().indexes().toArray().slice(0, -1)
        fnClick:
          if window.isSafari()
            undefined  # Use the original flash function
          else
            ( nButton, oConfig, oFlash ) ->
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
    trigger: 'click'
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
          if response['revocable?']
            content += '<i>This entry is still pending confirmation. Please do not quote it yet.</i>'
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

window.isSafari = ->
  navigator.userAgent.indexOf('Safari') != -1 && navigator.userAgent.indexOf('Chrome') == -1
