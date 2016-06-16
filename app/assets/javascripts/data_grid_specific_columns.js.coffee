# Specific configurations for particular DataTables, including callbacks
window.configs =
  'linkage-groups':
    columnDefs:
      [
        targets: 'linkage_maps_linkage_map_label_column'
        render: (data, type, full, meta) ->
          modelIdUrl('linkage_maps', data, full[full.length - 2])
      ]

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
        targets: ['map_locus_hits_associated_sequence_id_column', 'map_locus_hits_bac_hit_seq_id_column']
        render: (data, type, full, meta) ->
          if data && full[meta['col'] + 1].indexOf("NCBI") > -1
            '<a href="http://www.ncbi.nlm.nih.gov/nucgss/' + data + '" target="_blank">' + data + '</a>'
          else
            data
      ,
        targets: 'map_locus_hits_atg_hit_seq_id_column'
        render: (data, type, full, meta) ->
          if data
            ensemblId = data.split('.')[0]
            '<a href="http://plants.ensembl.org/Multi/Search/Results?species=Brassica;idx=;q=' + ensemblId + '" target="_blank">' + data + '</a>'
          else
            ''
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
        targets: 'marker_assays_marker_assay_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('marker_assays', data, full[full.length - 4])
      ,
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
          modelIdUrl('plant_lines', data, full[full.length - 3])
      ,
        targets: 'plant_varieties_plant_variety_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('plant_varieties', data, full[full.length - 2])
      ]

  'plant-lines':
    columnDefs:
      [
        targets: 'plant_varieties_plant_variety_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('plant_varieties', data, full[full.length - 2])
      ,
        targets: 'plant_lines_sequence_identifier_column'
        render: (data, type, full, meta) ->
          if data && data.indexOf("SR") == 0
            '<a href="http://www.ncbi.nlm.nih.gov/sra/' + data + '" target="_blank">' + data + '</a>'
          else
            data
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
      ,
        targets: 'plant_trials_layout_file_name_column'
        render: (data, type, full, meta) ->
          if data
            '<a href="plant_trials/' + full[full.length - 1] + '">Show</a>'
          else
            ''
      ,
        targets: 'plant_trials_id_column'
        render: (data, type, full, meta) ->
          '<a href="trial_scorings/' + data + '">Show</a>'
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

  'probes':
    columnDefs:
      [
        targets: 'probes_sequence_id_column'
        render: (data, type, full, meta) ->
          if data && full[meta['col'] + 1].indexOf("NCBI") > -1
            '<a href="http://www.ncbi.nlm.nih.gov/nucgss/' + data + '" target="_blank">' + data + '</a>'
          else
            data
      ]

  'qtl':
    columnDefs:
      [
        targets: 'linkage_groups_linkage_group_label_column'
        render: (data, type, full, meta) ->
          modelIdUrl('linkage_groups', data, full[full.length - 7])
      ,
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
        targets: 'traits_name_column'
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
        targets: 'traits_name_column'
        render: (data, type, full, meta) ->
          if data && full[7] && full[7].indexOf("TO:") > -1
            '<a href="http://browser.planteome.org/amigo/term/' + full[7] + '" target="_blank">' + data + '</a>'
          else
            data
      ,
        targets: 'plant_parts_plant_part_column'
        render: (data, type, full, meta) ->
          if data && full[8] && full[8].indexOf("PO:") > -1
            '<a href="http://browser.planteome.org/amigo/term/' + full[8] + '" target="_blank">' + data + '</a>'
          else
            data
      ,
        targets: 'related-specific'
        render: (data, type, full, meta) ->
          if full[full.length - 2]
            plant_trials_query = ('query[id][]=' + item for item in full[full.length - 2]).join('&')
          '<div class="dropdown">' +
            '<button class="btn btn-xs btn-info dropdown-toggle" type="button" data-toggle="dropdown" aria-expanded="true" title="Related data">' +
              'Related ' + '<span class="caret"></span>' +
            '</button>' +
            '<ul class="dropdown-menu" role="menu">' +
              createCounterLink('data_tables?model=trait_scores&query[trait_descriptors.id]=' + full[full.length - 1],
                full[full.length - 5],
                'trait scores') +
              createCounterLink('data_tables?model=plant_trials&' + plant_trials_query,
                if full[full.length - 2] then full[full.length - 2].length else 0,
                'plant trials') +
            '</ul>' +
          '</div>'
      ]

  'trait-scores':
    columnDefs:
      [
        targets: 'plant_populations_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('plant_populations', data, full[full.length - 6])
      ,
        targets: 'plant_lines_plant_line_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('plant_lines', data, full[full.length - 5])
      ,
        targets: 'plant_trials_plant_trial_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('plant_trials', data, full[full.length - 4])
      ,
        targets: 'traits_name_column'
        render: (data, type, full, meta) ->
          modelIdUrl('trait_descriptors', data, full[full.length - 3])
      ,
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
