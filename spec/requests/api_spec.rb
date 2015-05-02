require 'rails_helper'

RSpec.describe "API V1" do

  it_behaves_like "API resource", 'plant_line', PlantLine
  it_behaves_like "API resource", 'plant_variety', PlantVariety

end
