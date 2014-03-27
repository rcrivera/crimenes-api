class Geometry
  include Mongoid::Document
  field :type, type: String
  field :coordinates, type: Array

  embedded_in :crime
  
end
