require 'rails_helper'

RSpec.describe BaseForm do
  describe '.permitted_properties' do
    it "returns properties defined via 'property' method" do
      klass = Class.new(BaseForm) do
        property :faz
        property :gaz
      end

      expect(klass.permitted_properties).to eq([:faz, :gaz])
    end

    it "returns properties defined via 'properties' method" do
      klass = Class.new(BaseForm) do
        properties :faz, :gaz
      end

      expect(klass.permitted_properties).to eq([:faz, :gaz])
    end
  end
end
