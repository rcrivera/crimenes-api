class Crime
  include Mongoid::Document

  embeds_one :geometry
  embeds_one :properties

  index({"geometry.coordinates" => '2dsphere'}, { background: true })
  index({"property.time" => 1})

end

#rake db:mongoid:create_indexes