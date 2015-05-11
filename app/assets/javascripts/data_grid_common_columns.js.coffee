window.createCounterLink = (path, count, name) ->
  label = count + ' ' + name
  '<li role="presentation" class="' + ('disabled' if count == 0) + '">' +
    '<a role="menuitem" tabindex="-1" href="' +
    (if count > 0 then path else '#') +
    '">' + label + '</a>' +
  '</li>'


window.baseColumnDefs = (baseModel) ->
  baseModel = baseModel.replace(/-/g,'_')
  [
    targets: 'related'
    render: (data, type, full, meta) ->
      query = 'query[' + baseModel + '.id]=' + full[full.length - 1]
      relatedModels = $(meta.settings.nTable).find('.related').data('models')
      countDataIndex = $(meta.settings.nTable).find('.related').data('count-data-index')
      modelPaths = ('data_tables?model=' + model + '&' + query for model in relatedModels)
      modelNames = (model.replace(/_/g,' ') for model in relatedModels)
      modelCount = (full[countDataIndex + i] for model, i in relatedModels)
      '<div class="dropdown">' +
        '<button class="btn btn-xs btn-info dropdown-toggle" type="button" data-toggle="dropdown" aria-expanded="true" title="Related data">' +
          'Related ' +
          '<span class="caret"></span>' +
        '</button>' +
        '<ul class="dropdown-menu" role="menu">' +
          (createCounterLink(modelPaths[i], modelCount[i], modelNames[i]) for model, i in relatedModels).join('') +
        '</ul>' +
      '</div>'
  ,
    targets: 'annotations'
    render: (data, type, full, meta) ->
      objectId = full[full.length - 1]
      if objectId
        '<button class="btn btn-xs btn-info" data-popover-source="data_tables/' + objectId + '?model=' + baseModel + '" title="Metadata" data-toggle="tooltip"><i class="fa fa-info-circle fa-lg"></i></button>'
      else
        ''
  ,
    targets: 'taxonomy_terms_name_column'
    defaultContent: ''
    render: (data, type, full, meta) ->
      data.replace(/Brassica/, 'B.') if data
  ]
