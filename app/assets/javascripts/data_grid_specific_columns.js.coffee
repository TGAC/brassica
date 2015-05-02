# Specific configurations for particular DataTables, including callbacks
window.configs =
  'marker-assays':
    columnDefs:
      [
        targets: 'primer_a_column'
        render: (data, type, full, meta) ->
          modelIdUrl('primers', data, full[full.length - 4])
      ,
        targets: 'primer_b_column'
        render: (data, type, full, meta) ->
          modelIdUrl('primers', data, full[full.length - 3])
      ,
        targets: 'probe_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('probes', data, full[full.length - 2])
      ]

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
        targets: 'trait_scores_column'
        render: (data, type, full, meta) ->
          if data && full[7] && full[8]
            '<a href="data_tables?model=trait_scores&query[trait_descriptor_id]=' + full[7] +
            '&query[plant_scoring_units.plant_trial_id]=' + full[8] + '">' + data + '</a>'
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
          if data && full[10]
            '<a href="data_tables?model=plant_lines&query[id]=' + full[10] + '">' + data + '</a>'
          else
            ''
      ,
        targets: 'male_parent_line_column'
        render: (data, type, full, meta) ->
          if data && full[11]
            '<a href="data_tables?model=plant_lines&query[id]=' + full[11] + '">' + data + '</a>'
          else
            ''
      ]

window.modelIdUrl = (model, label, id) ->
  if model && label && id
    '<a href="data_tables?model=' + model + '&query[id]=' + id + '">' + label + '</a>'
  else
    label