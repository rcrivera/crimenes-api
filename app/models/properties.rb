class Properties
  include Mongoid::Document
  field :delito_id, type: String
  field :time, type: DateTime

  embedded_in :crime
  
end
