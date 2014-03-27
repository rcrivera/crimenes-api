class Crime
  include Mongoid::Document

  embeds_one :geometry
  embeds_one :properties

end
