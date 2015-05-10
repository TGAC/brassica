# Specific configurations for particular DataTables, including callbacks
window.configs =
  'linkage-maps':
    columnDefs:
      [
        targets: 'plant_populations_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('plant_populations', data, full[full.length - 3])
      ]

  'map-locus-hits':
    columnDefs:
      [
        targets: 'map_positions_map_position_column'
        render: (data, type, full, meta) ->
          modelIdUrl('map_positions', data, full[full.length - 4])
      ,
        targets: 'related-specific'
        render: (data, type, full, meta) ->
          '<div class="dropdown">' +
            '<button class="btn btn-xs btn-info dropdown-toggle" type="button" data-toggle="dropdown" aria-expanded="true" title="Related data">' +
            'Related ' +
            '<span class="caret"></span>' +
            '</button>' +
            '<ul class="dropdown-menu" role="menu">' +
            createRelatedLink('population_loci', full[full.length - 1]) +
            createRelatedLink('linkage_groups', full[full.length - 2]) +
            createRelatedLink('linkage_maps', full[full.length - 3]) +
            '</ul>' +
            '</div>'
      ]

  'map-positions':
    columnDefs:
      [
        targets: 'linkage_groups_linkage_group_label_column'
        render: (data, type, full, meta) ->
          modelIdUrl('linkage_groups', data, full[full.length - 3])
      ,
        targets: 'population_loci_mapping_locus_column'
        render: (data, type, full, meta) ->
          modelIdUrl('population_loci', data, full[full.length - 2])
      ]

  'marker-assays':
    columnDefs:
      [
        targets: 'marker_assays_primer_a_column'
        render: (data, type, full, meta) ->
          modelIdUrl('primers', data, full[full.length - 4])
      ,
        targets: 'marker_assays_primer_b_column'
        render: (data, type, full, meta) ->
          modelIdUrl('primers', data, full[full.length - 3])
      ,
        targets: 'probes_probe_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('probes', data, full[full.length - 2])
      ]

  'plant-accessions':
    columnDefs:
      [
        targets: 'plant_lines_plant_line_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('plant_lines', data, full[full.length - 2])
      ]

  'plant-lines':
    columnDefs:
      [
        targets: 'plant_varieties_plant_variety_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('plant_varieties', data, full[full.length - 2])
      ]

  'plant-populations':
    columnDefs:
      [
        targets: 'plant_populations_female_parent_line_column'
        render: (data, type, full, meta) ->
          modelIdUrl('plant_lines', data, full[full.length - 3])
      ,
        targets: 'plant_populations_male_parent_line_column'
        render: (data, type, full, meta) ->
          modelIdUrl('plant_lines', data, full[full.length - 2])
      ]

  'plant-scoring-units':
    columnDefs:
      [
        targets: 'plant_trials_plant_trial_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('plant_trials', data, full[full.length - 2])
      ,
        targets: 'plant_accessions_plant_accession_column'
        render: (data, type, full, meta) ->
          modelIdUrl('plant_accessions', data, full[full.length - 3])
      ]

  'plant-trials':
    columnDefs:
      [
        targets: 'plant_populations_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('plant_populations', data, full[full.length - 3])
      ]

  'population-loci':
    columnDefs:
      [
        targets: 'plant_populations_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('plant_populations', data, full[full.length - 3])
      ,
        targets: 'marker_assays_marker_assay_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('marker_assays', data, full[full.length - 2])
      ]

  'qtl':
    columnDefs:
      [
        targets: 'qtl_jobs_qtl_job_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('qtl_jobs', data, full[full.length - 6])
      ,
        targets: 'plant_populations_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('plant_populations', data, full[full.length - 5])
      ,
        targets: 'linkage_maps_linkage_map_label_column'
        render: (data, type, full, meta) ->
          modelIdUrl('linkage_maps', data, full[full.length - 4])
      ,
        targets: 'trait_descriptors_descriptor_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('trait_descriptors', data, full[full.length - 3])
      ,
        targets: 'related-specific'
        render: (data, type, full, meta) ->
          '<div class="dropdown">' +
            '<button class="btn btn-xs btn-info dropdown-toggle" type="button" data-toggle="dropdown" aria-expanded="true" title="Related data">' +
            'Related ' +
            '<span class="caret"></span>' +
            '</button>' +
            '<ul class="dropdown-menu" role="menu">' +
            createRelatedLink('linkage_maps', full[full.length - 4]) +
            createRelatedLink('plant_populations', full[full.length - 5]) +
            createRelatedLink('qtl_jobs', full[full.length - 6]) +
            '</ul>' +
            '</div>'
      ]

  'trait-descriptors':
    columnDefs:
      [
        targets: 'plant_populations_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('plant_populations', data, full[full.length - 3])
      ,
        targets: 'plant_trials_project_descriptor_column'
        render: (data, type, full, meta) ->
          if data
            '<a href="data_tables?model=plant_trials&query[project_descriptor]=' + data + '">' + data + '</a>'
          else
            ''
      ,
        targets: 'trait_descriptors_trait_scores_column'
        render: (data, type, full, meta) ->
          if data && full[8] && full[9]
            '<a href="data_tables?model=trait_scores&query[trait_descriptor_id]=' + full[9] +
              '&query[plant_scoring_units.plant_trial_id]=' + full[8] + '">' + data + '</a>'
          else
            ''
      ,
        targets: 'trait_descriptors_qtl_column'
        render: (data, type, full, meta) ->
          if data && data != "0" && full[full.length - 1]
            '<a href="data_tables?model=qtl&query[processed_trait_datasets.trait_descriptor_id]=' + full[full.length - 1] + '">' + data + '</a>'
          else
            ''
      ]

  'trait-scores':
    columnDefs:
      [
        targets: 'plant_scoring_units_scoring_unit_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('plant_scoring_units', data, full[full.length - 2])
      ]


window.modelIdUrl = (model, label, id) ->
  if model && label && id
    '<a href="data_tables?model=' + model + '&query[id]=' + id + '">' + label + '</a>'
  else
    label


window.createRelatedLink = (model, value) ->
  createCounterLink('data_tables?model=' + model + '&query[id]=' + value,
    (if value then 1 else 0),
    model.replace(/_/g,' '))
