# Specific configurations for particular DataTables, including callbacks
window.configs =
  'plant-lines':
    columnDefs:
      [
        targets: 'plant_varieties_plant_variety_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('plant_varieties', data, full[8])
      ]

  'trait-descriptors':
    columnDefs:
      [
        targets: 'plant_trials_project_descriptor_column'
        render: (data, type, full, meta) ->
          if data
            '<a href="data_tables?model=plant_trials&query[project_descriptor]=' + data + '">' + data + '</a>'
          else
            ''
      ,
        targets: 'trait_descriptors_trait_scores_column'
        render: (data, type, full, meta) ->
          if data && full[7] && full[8]
            '<a href="data_tables?model=trait_scores&query[trait_descriptor_id]=' + full[8] +
            '&query[plant_scoring_units.plant_trial_id]=' + full[7] + '">' + data + '</a>'
          else
            ''
      ,
        targets: 'trait_descriptors_qtl_column'
        render: (data, type, full, meta) ->
          if data && full[full.length - 1]
            '<a href="data_tables?model=qtl&query[processed_trait_datasets.trait_descriptor_id]=' + full[full.length - 1] + '">' + data + '</a>'
          else
            ''
      ]

  'plant-trials':
    columnDefs:
      [
        targets: 'plant_populations_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('plant_populations', data, full[full.length - 3])
      ]

  'trait-scores':
    columnDefs:
      [
        targets: 'plant_scoring_units_scoring_unit_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('plant_scoring_units', data, full[full.length - 2])
      ]

  'plant-populations':
    columnDefs:
      [
        targets: 'plant_populations_female_parent_line_column'
        render: (data, type, full, meta) ->
          modelIdUrl('plant_lines', data, full[10])
      ,
        targets: 'plant_populations_male_parent_line_column'
        render: (data, type, full, meta) ->
          modelIdUrl('plant_lines', data, full[11])
      ]

  'qtl':
    columnDefs:
      [
        targets: 'plant_populations_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('plant_populations', data, full[full.length - 4])
      ,
        targets: 'linkage_maps_linkage_map_label_column'
        render: (data, type, full, meta) ->
          modelIdUrl('linkage_maps', data, full[full.length - 3])
      ,
        targets: 'trait_descriptors_descriptor_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('trait_descriptors', data, full[full.length - 2])
      ]


window.modelIdUrl = (model, label, id) ->
  if model && label && id
    '<a href="data_tables?model=' + model + '&query[id]=' + id + '">' + label + '</a>'
  else
    label
