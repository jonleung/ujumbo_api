class GoogleDocPipe < Pipe
	include Mongoid::Document
	self.mass_assignment_sanitizer = :strict
	include Mongoid::Timestamps
	include Mongoid::Paranoia

	def flow
		google_doc = GoogleDoc.where(id: self.static_properties[:google_doc_id]).first
		worksheet = google_doc.google_doc_worksheets.where(name: self.static_properties[:worksheet_name]).first
		google_doc.setup
		case self.action
		when :create_row
			output = worksheet.create_row(combined_properties)
		when :update_row
			find_by_params = combined_properties.select { |k,v| k.start_with?("find_by_") }
			find_by_params = Hash[find_by_params.map {|k, v| [k.gsub("find_by_", ""), v] }]
			update_to_params = combined_properties.select { |k,v| k.start_with?("update_to_") }
			update_to_params = Hash[update_to_params.map {|k, v| [k.gsub("update_to_", ""), v] }]
			output = worksheet.update_all(find_by_params, update_to_params)
		when :destroy_row
			output = worksheet.delete_all(self.static_properties[:destroy_by_params])
		when :find_row
			output = worksheet.find(self.static_properties[:find_by_params])
		when :create_column
			output = worksheet.add_column_key(self.static_properties[:column_to_add])
		when :delete_column
			output = worksheet.delete_column_key(self.static_properties[:column_to_destroy])
		end

		writeback_to_pipelined_hash(GoogleDoc.to_s, output)
	end

end