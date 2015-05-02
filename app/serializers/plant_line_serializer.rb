class PlantLineSerializer < ActiveModel::Serializer
  # attributes *(PlantLine.table_columns + PlantLine.ref_columns)
  attributes :id
end
