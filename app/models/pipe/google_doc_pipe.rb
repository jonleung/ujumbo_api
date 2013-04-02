class GoogleDocPipe < Pipe
	include Mongoid::Document
	self.mass_assignment_sanitizer = :strict
	include Mongoid::Timestamps
	include Mongoid::Paranoia

	def flow
		google_doc = GoogleDoc.where(id: self.static_properties[:google_doc_id]).first
		case self.action
		when :create_row
			output = google_doc.create_row(combined_properties)
		when :update_row
			find_by_params = combined_properties.select { |k,v| k.start_with?("find_by_") }
			find_by_params = Hash[find_by_params.map {|k, v| [k.gsub("find_by_", ""), v] }]
			update_to_params = combined_properties.select { |k,v| k.start_with?("update_to_") }
			update_to_params = Hash[update_to_params.map {|k, v| [k.gsub("update_to_", ""), v] }]
			output = google_doc.update_all(find_by_params, update_to_params)
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