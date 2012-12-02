module Inputs
	class GoogleDoc
		attr_accessor :session
		attr_accessor :filename
		attr_accessor :worksheet_name
		attr_accessor :file_obj
		attr_accessor :worksheet_obj
		attr_accessor :auth_tokens

		def initialize(username, password, filename, worksheet_name)
			@session = GoogleDrive.login(username, password)
			@auth_tokens = @session.auth_tokens
			@filename = filename
			@worksheet_name = worksheet_name
			@file_obj = @session.spreadsheet_by_title(filename)
			@worksheet_obj = @file_obj.worksheet_by_title(worksheet_name)
		end

		def create_spreadsheet(filename)
			spreadsheet = @session.create_spreadsheet(filename)

		end

		#returns an array of hashes, where each hash is a row
		def get_all_rows()
			@worksheet_obj.list.to_hash_array
		end

		def get_row_by_attribute(attr_name, attr_val)
			@worksheet_obj.list.each do |row|
				#puts row.to_hash
				if(row[attr_name] == attr_val) 
			 		return row.to_hash
				end
			end
		end

	end

end