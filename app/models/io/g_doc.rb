class GDoc
	include Mongoid::Document
	field :name, type: String
	field :data, type: String
	embeds_many :document_states
end

class DocumentState
	include Mongoid::Document
	field :last_data, type: String
	embedded_in :gDoc
end
