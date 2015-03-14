require 'rails_helper'

RSpec.describe TaxonomyTerm do
  it 'prevents duplicated names' do
    tt = create(:taxonomy_term)
    expect { create(:taxonomy_term, name: tt.name) }.
      to raise_error ActiveRecord::RecordInvalid
  end

  it 'prevents duplicated names even without callbacks' do
    tt = create(:taxonomy_term)
    tt2 = create(:taxonomy_term)
    expect { tt2.update_attribute(:name, tt.name) }.
      to raise_error ActiveRecord::RecordNotUnique
  end

  describe '#children_of' do
    before(:each) do
      @r1 = create(:taxonomy_term)
      @r2 = create(:taxonomy_term)
    end

    it 'properly returns roots' do
      expect(TaxonomyTerm.children_of(nil)).to contain_exactly @r1, @r2
    end

    it 'returns children' do
      t1 = create(:taxonomy_term, parent: @r1)
      t2 = create(:taxonomy_term, parent: @r1)
      create(:taxonomy_term, parent: @r2)
      expect(TaxonomyTerm.children_of(@r1)).to contain_exactly t1, t2
    end
  end
end
