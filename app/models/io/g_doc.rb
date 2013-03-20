class GDoc
	include Mongoid::Document
	self.mass_assignment_sanitizer = :strict
	include Mongoid::Timestamps
	include Mongoid::Paranoia

	field :name, type: String
	field :data, type: String
	field :schema, type: Hash  # stores the schema, which comes as a hash 
	embeds_many :document_states

	def self.store_schema(schema, doc_name)
		gdoc = GDoc.where(name: doc_name).last
		gdoc.write_attribute(:schema, schema)
	end
end

class DocumentState
	include Mongoid::Document
	self.mass_assignment_sanitizer = :strict
	include Mongoid::Timestamps
	include Mongoid::Paranoia

	field :rows_deleted, type: Array
	field :rows_updated, type: Array
	field :rows_created, type: Array
	
	field :last_data, type: String
	embedded_in :gDoc
end
