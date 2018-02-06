require 'rails_helper'

RSpec.describe Submission::PlantTrialFinalizer do

  let(:submission) { create(:submission, :trial) }
  let(:plant_population) { create(:plant_population, user: submission.user) }
  let(:existing_trait_descriptor) { create(:trait_descriptor) }
  let(:existing_accession) {
    create(:plant_accession, plant_accession: 'existing_acc',
                             originating_organisation: 'Organisation Existing',
                             year_produced: '2017',
                             plant_line: create(:plant_line, plant_variety: nil))
  }
  let(:existing_variety) { create(:plant_variety) }
  let(:existing_line) { create(:plant_line, plant_variety: nil) }
  let(:trait) { create(:trait) }
  let(:trait_other) { create(:trait) }
  let(:plant_part) { create(:plant_part) }

  subject { described_class.new(submission) }

  context 'given submission with valid content' do
    let(:plant_trial_attrs) {
      attributes_for(:plant_trial).merge(plant_population_id: plant_population.id)
    }
    let(:new_trait_descriptors_attrs) {
      [
        {
          trait: trait.name,
          comments: "Impedit dolorem sunt dolorem voluptate.",
          data_provenance: "Et qui aut deserunt recusandae voluptatum alias quia aliquid.",
          data_owned_by: "Cormier and Sons",
          units_of_measurements: "Sint et nisi et minus quo deleniti. (%)",
          scoring_method: "Et laborum velit voluptatem dolorem culpa consequatur occaecati.",
          materials: "Voluptate quas ipsam dolor et quia."
        },
        {
          trait: trait_other.name,
          comments: "Dignissimos necessitatibus qui iste impedit itaque.",
          data_provenance: "Alias voluptates ea aut et quis sunt ad.",
          data_owned_by: "Bosco Inc",
          units_of_measurements: "Sunt qui suscipit quis accusantium nihil voluptas assumenda earum. (%)",
          scoring_method: "Sunt quia aliquam ullam magnam reprehenderit earum ut.",
          plant_part_id: plant_part.id
        }
      ]
    }
    let(:layout_upload) { create(:submission_upload, :plant_trial_layout, submission: submission) }

    before do
      submission.content.update(:step01, plant_trial_attrs)
      submission.content.update(:step02,
        trait_descriptor_list: new_trait_descriptors_attrs.map{ |td| td[:trait] } + [existing_trait_descriptor.id],
        new_trait_descriptors: new_trait_descriptors_attrs)
      submission.content.update(:step04,
        trait_mapping: { 0 => 2, 1 => 1, 2 => 0 },
        trait_scores: {
          'p1' => {},
          'p2' => { 1 => 'x' },
          'p3' => { 0 => 'y', 2 => 'z' },
          'p4' => { 2 => '' }
        },
        accessions: {
          'p1' => { plant_accession: 'new_acc1', originating_organisation: 'Organisation A', year_produced: '2017' },
          'p2' => { plant_accession: existing_accession.plant_accession,
                    originating_organisation: existing_accession.originating_organisation,
                    year_produced: existing_accession.year_produced },
          'p3' => { plant_accession: 'new_acc1', originating_organisation: 'Organisation A', year_produced: '2017' },
          'p4' => { plant_accession: 'new_acc2', originating_organisation: 'Organisation A', year_produced: '2017' }
        },
        lines_or_varieties: {
          'p1' => { relation_class_name: 'PlantVariety', relation_record_name: 'pv' },
          'p2' => { relation_class_name: 'PlantVariety', relation_record_name: 'pv' },
          'p3' => { relation_class_name: 'PlantVariety', relation_record_name: 'pv' },
          'p4' => { relation_class_name: 'PlantVariety', relation_record_name: 'pv' }
        }
      )
      submission.content.update(:step05, layout_upload_id: layout_upload.id)
      submission.content.update(:step06, plant_trial_attrs.slice(
        :data_owned_by, :data_provenance, :comments).merge(visibility: 'published')
      )
    end

    it 'creates new trait descriptors' do
      expect{ subject.call }.to change{ TraitDescriptor.count }.by(2)

      expect(subject.new_trait_descriptors.size).to eq 2
      subject.new_trait_descriptors.each_with_index do |trait_descriptor, idx|
        expect(trait_descriptor).to be_persisted
        expect(trait_descriptor.attributes).to include(
          'comments' => new_trait_descriptors_attrs[idx][:comments],
          'data_provenance' => new_trait_descriptors_attrs[idx][:data_provenance],
          'units_of_measurements' => new_trait_descriptors_attrs[idx][:units_of_measurements],
          'scoring_method' => new_trait_descriptors_attrs[idx][:scoring_method],
          'data_owned_by' => new_trait_descriptors_attrs[idx][:data_owned_by],
          'entered_by_whom' => submission.user.full_name,
          'date_entered' => Date.today,
          'published' => true,
          'user_id' => submission.user.id
        )
        expect(trait_descriptor.trait_name).to eq new_trait_descriptors_attrs[idx][:trait]
        expect(trait_descriptor.plant_part.try(:id)).to eq new_trait_descriptors_attrs[idx][:plant_part_id]
        expect(trait_descriptor.published_on).to be_within(5.seconds).of(Time.now)
      end
    end

    it 'creates plant trial' do
      expect{ subject.call }.to change{ PlantTrial.count }.by(1)

      expect(PlantTrial.last.plant_trial_name).to eq plant_trial_attrs[:plant_trial_name]
      expect(PlantTrial.last.comments).to eq plant_trial_attrs[:comments]
      expect(PlantTrial.last.entered_by_whom).to eq submission.user.full_name
      expect(PlantTrial.last.date_entered).to eq Date.today
      expect(PlantTrial.last.published).to be_truthy
      expect(PlantTrial.last.user).to eq submission.user
      expect(PlantTrial.last.published_on).to be_within(5.seconds).of(Time.now)
    end

    it 'associates created plant trial with plant population' do
      subject.call

      expect(PlantTrial.last.plant_population).to eq plant_population
    end

    it 'assigns layout image to created plant trial' do
      subject.call

      expect(PlantTrial.last.layout.original_filename).to eq(layout_upload.file.original_filename)
    end

    it 'creates plant scoring units' do
      expect{ subject.call }.to change{ PlantScoringUnit.count }.by(4)

      expect(PlantScoringUnit.pluck(:scoring_unit_name)).to match_array %w(p1 p2 p3 p4)
      expect(PlantScoringUnit.pluck(:entered_by_whom).uniq).to eq [submission.user.full_name]
      expect(PlantScoringUnit.pluck(:plant_trial_id).uniq).to eq [plant_population.plant_trials.first.id]
    end

    it 'creates new plant accessions, where no old are found' do
      expect{ subject.call }.to change{ PlantAccession.count }.by(2)

      expect(PlantAccession.pluck(:plant_accession)).
        to match_array %w(existing_acc new_acc1 new_acc2)
      expect(PlantAccession.pluck(:originating_organisation).uniq).
        to match_array ['Organisation Existing', 'Organisation A']
      expect(PlantAccession.where(entered_by_whom: submission.user.full_name).count).to eq 2
    end

    it 'associates new and old accessions with plant scoring units' do
      subject.call

      expect(existing_accession.reload.plant_scoring_units.count).to eq 1
      expect(PlantAccession.find_by(plant_accession: 'new_acc1').plant_scoring_units.count).to eq 2
      expect(PlantAccession.find_by(plant_accession: 'new_acc2').plant_scoring_units.count).to eq 1
    end

    it 'creates trait scores for adequate trait descriptors' do
      expect{ subject.call }.to change{ TraitScore.count }.by(3)

      expect(TraitScore.pluck(:score_value)).to match_array %w(x y z)
      expect(TraitScore.pluck(:entered_by_whom).uniq).to eq [submission.user.full_name]
      expect(TraitScore.find_by(score_value: 'x').trait_descriptor.trait_name).
        to eq new_trait_descriptors_attrs[1][:trait]
      expect(TraitScore.find_by(score_value: 'x').plant_scoring_unit.scoring_unit_name).to eq 'p2'
      expect(TraitScore.find_by(score_value: 'y').trait_descriptor.trait_name).
        to eq existing_trait_descriptor.trait_name
      expect(TraitScore.find_by(score_value: 'y').plant_scoring_unit.scoring_unit_name).to eq 'p3'
      expect(TraitScore.find_by(score_value: 'z').trait_descriptor.trait_name).
        to eq new_trait_descriptors_attrs[0][:trait]
      expect(TraitScore.find_by(score_value: 'z').plant_scoring_unit.scoring_unit_name).to eq 'p3'
    end

    it 'updates counter caches for trait scores accordingly' do
      expect{ subject.call }.to change{ TraitScore.count }.by(3)

      expect(PlantScoringUnit.pluck(:scoring_unit_name, :trait_scores_count)).
        to match_array [['p1', 0], ['p2', 1], ['p3', 2], ['p4', 0]]
      expect(TraitDescriptor.pluck(:trait_scores_count)).
        to match_array [1, 1, 1]
    end

    context 'when dealing with plant lines and plant varieties' do
      it 'creates or assigns plant varieties for new accessions only' do
        submission.content.update(:step04,
          submission.content.to_h.merge(
            lines_or_varieties: {
              'p1' => { relation_class_name: 'PlantVariety', relation_record_name: 'New variety to be created' },
              'p2' => { relation_class_name: 'PlantVariety', relation_record_name: 'New variety not to be created' },
              'p3' => { relation_class_name: 'PlantVariety', relation_record_name: 'New variety already created' },
              'p4' => { relation_class_name: 'PlantVariety', relation_record_name: existing_variety.plant_variety_name }
            }
          )
        )

        expect{ subject.call }.to change{ PlantVariety.count }.by(1)
        expect(PlantVariety.pluck(:plant_variety_name)).
          to match_array [existing_variety.plant_variety_name, 'New variety to be created']
        expect(existing_accession.reload.plant_variety).to be_nil
        expect(PlantAccession.find_by_plant_accession('new_acc1').plant_variety.plant_variety_name).
          to eq 'New variety to be created'
        expect(PlantAccession.find_by_plant_accession('new_acc2').plant_variety.plant_variety_name).
          to eq existing_variety.plant_variety_name
      end

      it 'assigns plant lines for new accessions only' do
        submission.content.update(:step04,
          submission.content.to_h.merge(
            lines_or_varieties: {
              'p1' => { relation_class_name: 'PlantLine', relation_record_name: existing_line.plant_line_name },
              'p2' => { relation_class_name: 'PlantLine', relation_record_name: 'New line not to be created' },
              'p3' => { relation_class_name: 'PlantLine', relation_record_name: existing_line.plant_line_name },
              'p4' => { relation_class_name: 'PlantLine', relation_record_name: existing_line.plant_line_name }
            }
          )
        )

        expect{ subject.call }.to change{ PlantLine.count }.by(0)
        expect(existing_accession.reload.plant_line.plant_line_name).not_to eq 'New line not to be created'
        expect(PlantAccession.find_by_plant_accession('new_acc1').plant_line.plant_line_name).
          to eq existing_line.plant_line_name
        expect(PlantAccession.find_by_plant_accession('new_acc2').plant_line.plant_line_name).
          to eq existing_line.plant_line_name
      end

      it 'does not mind nil PL/PV values for existing accession PSUs' do
        submission.content.update(:step04,
          submission.content.to_h.merge(
            trait_scores: {
              'p1' => {}
            },
            accessions: {
              'p1' => { plant_accession: existing_accession.plant_accession,
                        originating_organisation: existing_accession.originating_organisation,
                        year_produced: existing_accession.year_produced}
            },
            lines_or_varieties: {
              'p1' => { relation_class_name: 'PlantLine', relation_record_name: nil }
            }
          )
        )

        expect{ subject.call }.to change{ PlantScoringUnit.count }.by(1)
      end

      it 'rollbacks when encountered nil PL/PV values for nonexisting accession PSUs' do
        # We let nil PV/PL through the parser, for existing PA.
        # So we need to check in the finalizer if they still exist
        submission.content.update(:step04,
          submission.content.to_h.merge(
            lines_or_varieties: {
              'p1' => { relation_class_name: 'PlantVariety', relation_record_name: nil },
              'p2' => { relation_class_name: 'PlantVariety', relation_record_name: nil },
              'p3' => { relation_class_name: 'PlantLine', relation_record_name: nil },
              'p4' => { relation_class_name: 'PlantLine', relation_record_name: nil }
            }
          )
        )

        expect{ subject.call }.to change{ related_object_count }.by(0)
        expect(submission.finalized?).to be_falsey
      end
    end

    context 'when parsing technical replicate data' do
      before :each do
        submission.content.update(:step04,
          submission.content.to_h.merge(
            trait_mapping: { 0 => 0, 1 => 0, 2 => 1, 3 => 2, 4 => 2 },
            replicate_numbers: { 0 => 1, 1 => 2, 2 => 0, 3 => 1, 4 => 2 },
            trait_scores: {
              'p1' => {},
              'p2' => { 0 => '1.1', 1 => '1.2', 2 => '1.3', 3 => '1.4', 4 => '1.5' },
              'p3' => { 0 => '1.1', 1 => '1.2', 3 => '1.4', 4 => '1.5' },
              'p4' => { 2 => '1.3', 3 => '1.4', 4 => '1.5' }
            }
          )
        )
      end

      it 'assigns replicate numbers accordingly' do
        subject.call

        expect(PlantScoringUnit.find_by_scoring_unit_name('p1').trait_scores).to be_empty
        p2 = PlantScoringUnit.find_by_scoring_unit_name('p2')
        expect(p2.trait_scores.pluck(:score_value, :technical_replicate_number)).
          to match_array [['1.1', 1], ['1.2', 2], ['1.3', 1], ['1.4', 1], ['1.5',2]]
        p3 = PlantScoringUnit.find_by_scoring_unit_name('p3')
        expect(p3.trait_scores.pluck(:score_value, :technical_replicate_number)).
          to match_array [['1.1', 1], ['1.2', 2], ['1.4', 1], ['1.5',2]]
        p4 = PlantScoringUnit.find_by_scoring_unit_name('p4')
        expect(p4.trait_scores.pluck(:score_value, :technical_replicate_number)).
          to match_array [['1.3', 1], ['1.4', 1], ['1.5',2]]
      end
    end

    context 'when parsing design factors' do
      before :each do
        submission.content.update(:step04,
          submission.content.to_h.merge(
            design_factor_names: ['polytunnel', 'rep', 'sub_block', 'pot_number'],
            design_factors: {
              'p1' => ['A', '1', '1', '1'],
              'p2' => [],
              'p3' => ['A', '2', '1'],
              'p4' => ['B', '2', '', '2']
            }
          )
        )
      end

      it 'sets correct trial design_factors value' do
        subject.call
        expect(PlantTrial.last.design_factors).to eq 'polytunnel / rep / sub_block / pot_number'
      end

      it 'records design factors data for plant scoring units' do
        subject.call

        p1 = PlantScoringUnit.find_by_scoring_unit_name('p1')
        expect(p1.design_factor).not_to be_nil
        expect(p1.design_factor.design_unit_counter).to eq '1'
        expect(p1.design_factor.design_factors).
          to eq %w(polytunnel_A rep_1 sub_block_1 pot_number_1)
        expect(p1.design_factor.date_entered).to eq Date.today
        expect(p1.design_factor.entered_by_whom).to eq submission.user.full_name
        expect(PlantScoringUnit.find_by_scoring_unit_name('p2').design_factor).to be_nil
        p3 = PlantScoringUnit.find_by_scoring_unit_name('p3')
        expect(p3.design_factor).not_to be_nil
        expect(p3.design_factor.design_unit_counter).to eq '1'
        expect(p3.design_factor.design_factors).
          to eq %w(polytunnel_A rep_2 sub_block_1)
        p4 = PlantScoringUnit.find_by_scoring_unit_name('p4')
        expect(p4.design_factor).not_to be_nil
        expect(p4.design_factor.design_unit_counter).to eq '2'
        expect(p4.design_factor.design_factors).
          to eq %w(polytunnel_B rep_2 sub_block_ pot_number_2)
      end
    end

    context "when parsing environment data" do
      before do
        submission.content.update(:step04, environment: {
          day_temperature: ["degree Celcius", 20],
          night_temperature: ["degree Celcius", 10],
          co2_controlled: "controlled",
          lamps: [["fluorescent tubes", "2 per plant"], ["new secret lamps", nil]],
          containers: [["new secret containers", nil]],
          topological_descriptors: [["slope", "45 degree"]],
          rooting_media: [["clay soil", "high red clay content"]]
        })
      end

      before do
        create(:lamp_type, name: "fluorescent tubes")
        create(:measurement_unit, name: "degree Celcius")
        create(:plant_treatment_type, name: "plant growth medium treatment", term: "PECO:0007147")
      end

      it "records environment properties" do
        subject.call

        environment = PlantTrial.last.environment

        expect(environment).to be_persisted
        expect(environment.co2_controlled).to be_truthy
        expect(environment.lamps[0].lamp_type).to eq(LampType.find_by!(name: "fluorescent tubes"))
        expect(environment.lamps[0].description).to eq("2 per plant")
        expect(environment.lamps[1].lamp_type).to eq(LampType.find_by!(name: "new secret lamps"))
        expect(environment.lamps[1].description).to be_nil
        expect(environment.containers[0].container_type).to eq(ContainerType.find_by!(name: "new secret containers"))
        expect(environment.containers[0].description).to be_nil
        expect(environment.topological_descriptors[0].topological_factor).
          to eq(TopologicalFactor.find_by!(name: "slope"))
        expect(environment.topological_descriptors[0].description).to eq("45 degree")
        expect(environment.rooting_media[0].medium_type).to eq(PlantTreatmentType.find_by!(name: "clay soil"))
        expect(environment.rooting_media[0].description).to eq("high red clay content")
      end
    end

    context "when parsing treatment data" do
      before do
        submission.content.update(:step04, treatment: {
          pesticide: [["diuron treatment", "Sprayed the hell out of them pests!"],
                      ["new secret treatment", "Not telling anything"]]
        })
      end

      before do
        root_treatment_type = create(:plant_treatment_type, name: "pesticide treatment",
                                                            term: PlantTreatmentType::PESTICIDE_ROOT_TERM)
        create(:plant_treatment_type, name: "diuron treatment", parent_ids: [root_treatment_type.id])
      end

      it "records environment properties" do
        subject.call

        treatment = PlantTrial.last.treatment

        expect(treatment).to be_persisted
        expect(treatment.pesticide_applications[0].treatment_type).
          to eq(PlantTreatmentType.find_by!(name: "diuron treatment"))

        expect(treatment.pesticide_applications[1].treatment_type).
          to eq(PlantTreatmentType.find_by!(name: "new secret treatment"))

        expect(treatment.pesticide_applications[0].description).to eq("Sprayed the hell out of them pests!")
        expect(treatment.pesticide_applications[1].description).to eq("Not telling anything")
      end
    end

    it 'makes submission and created objects published' do
      subject.call

      expect(TraitDescriptor.all).to all be_published
      expect(TraitScore.all).to all be_published
      expect(PlantScoringUnit.all).to all be_published
      expect(PlantTrial.all).to all be_published
      expect(PlantAccession.all).to all be_published
      expect(submission).to be_published
    end

    context 'when visibility set to private' do
      before do
        submission.content.update(:step06, visibility: 'private')
      end

      it 'makes submission and created objects private' do
        subject.call

        plant_trial = submission.submitted_object
        plant_scoring_units = plant_trial.plant_scoring_units
        trait_scores = plant_trial.plant_scoring_units.map(&:trait_scores).flatten

        expect(submission).not_to be_published
        expect(plant_trial).not_to be_published
        expect(plant_scoring_units.map(&:published?)).to all be_falsey
        expect(trait_scores.map(&:published?)).to all be_falsey
        expect(PlantAccession.where.not(id: existing_accession.id).map(&:published?)).to all be_falsey
      end
    end

    context 'when encountered broken data' do
      it 'rollbacks when no Population is found' do
        plant_population.destroy
        expect{ subject.call }.to change{ related_object_count }.by(0)
        expect(submission.finalized?).to be_falsey
      end

      it 'rollbacks when no Trait Descriptor is found' do
        existing_trait_descriptor.destroy
        expect{ subject.call }.to change{ related_object_count }.by(0)
        expect(submission.finalized?).to be_falsey
      end

      it 'raises an error when there is missing accession data' do
        submission.content.update(:step04,
          trait_mapping: { 0 => 2, 1 => 1, 2 => 0 },
          trait_scores: {
            'p1' => { 0 => 'y', 2 => 'z' },
            'p2' => { 0 => 'y', 2 => 'z' }
          },
          accessions: {
            'p1' => { plant_accession: 'new_acc1' }
          }
        )

        expect{ subject.call }.to raise_error RuntimeError, 'Misformed parsed plant accession data.'
        expect{ subject.call rescue nil }.not_to change{ related_object_count }
        expect(submission.finalized?).to be_falsey
      end

      it 'raises an error when there is no plant line or plant variety information for new accession' do
        submission.content.update(:step04,
          accessions: {
            'p1' => { plant_accession: 'new_acc1', originating_organisation: 'oo', year_produced: '2017' }
          },
          lines_or_varieties: {}
        )

        expect{ subject.call }.to raise_error RuntimeError,
                                              'Required plant line or plant variety data not available after parsing.'
        expect{ subject.call rescue nil }.not_to change{ related_object_count }
        expect(submission.finalized?).to be_falsey
      end

      it 'raises an error when there is strange relation information for new accession' do
        submission.content.update(:step04,
          accessions: {
            'p1' => { plant_accession: 'new_acc1', originating_organisation: 'oo', year_produced: '2017' }
          },
          lines_or_varieties: {
            'p1' => { relation_class_name: 'PlantPopulation', relation_record_name: 'Why not?' }
          }
        )

        expect{ subject.call }.to raise_error RuntimeError,
                                              "Incorrect value [PlantPopulation] user for relation name for a new accession."
        expect{ subject.call rescue nil }.not_to change{ related_object_count }
        expect(submission.finalized?).to be_falsey
      end

      it 'rollbacks when a new plant line is encountered for a new plant accession' do
        submission.content.update(:step04,
          accessions: {
            'p1' => { plant_accession: 'new_acc1', originating_organisation: 'oo', year_produced: '2017' }
          },
          lines_or_varieties: {
            'p1' => { relation_class_name: 'PlantLine', relation_record_name: 'New line that should not be created' }
          }
        )

        expect{ subject.call }.to change{ related_object_count }.by(0)
        expect(submission.finalized?).to be_falsey
      end
    end

    def related_object_count
      PlantTrial.count +
        TraitScore.count +
        PlantScoringUnit.count +
        TraitDescriptor.count +
        PlantAccession.count +
        DesignFactor.count +
        PlantVariety.count
    end
  end
end
