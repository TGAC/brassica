require 'rails_helper'

RSpec.describe "API V1" do

  Brassica::Api.readable_models.each do |model_klass|
    describe model_klass do
      it_behaves_like "API resource", model_klass
    end
  end

end
