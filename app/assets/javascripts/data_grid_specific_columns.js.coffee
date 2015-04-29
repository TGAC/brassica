# Specific configurations for particular DataTables, including callbacks
window.configs =
  'plant-lines':
    columnDefs:
      [
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

  'plant-trials':
    columnDefs:
      [
        targets: 'name_column'
        render: (data, type, full, meta) ->
          if data && full[full.length - 3]
            '<a href="data_tables?model=plant_populations&query[id]=' + full[full.length - 3] + '">' + data + '</a>'
          else
            data
      ]

  'trait-scores':
    columnDefs:
      [
        targets: 'scoring_unit_name_column'
        render: (data, type, full, meta) ->
          if data && full[full.length - 2]
            '<a href="data_tables?model=plant_scoring_units&query[id]=' + full[full.length - 2] + '">' + data + '</a>'
          else
            data
      ]

  'plant-populations':
    columnDefs:
      [
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
