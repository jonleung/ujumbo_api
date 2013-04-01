class GoogleDocPipe < Pipe
	include Mongoid::Document
	self.mass_assignment_sanitizer = :strict
	include Mongoid::Timestamps
	include Mongoid::Paranoia

	def flow
		google_doc = GoogleDoc.where(id: self.static_properties[:google_doc_id]).first
		case self.action
		when :create_row
			output = google_doc.create_row(self.static_properties[:create_by_params])
		when :update_row
			debugger
			output = google_doc.update_all(self.static_properties[:find_by_params], self.static_properties[:update_to_params])
		when :destroy_row
			debugger
			output = google_doc.delete_all(self.static_properties[:destroy_by_params])
		when :find_row
			output = google_doc.find(self.static_properties[:find_by_params])
		when :create_column
			output = google_doc.add_column_key(self.static_properties[:column_to_add])
		when :delete_column
			output = google_doc.delete_column_key(self.static_properties[:column_to_destroy])
		end

		writeback_to_pipelined_hash(GoogleDoc.to_s, output)
	end

end