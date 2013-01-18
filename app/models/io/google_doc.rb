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

	def create_row(params)
		@worksheet_obj.list.push(params)
	end

	def where(params)
		
	end

	def find(params)
	end

	def delete(params)
		
	end

	def delete_all(params)
	end

	def all(params)
		@worksheet_obj.list.to_hash_array
	end

	def update(params)
		@worksheet_obj.list.update(params)
	end

	def update_all(params)
	end

	def replace(params)
	end

	def replace_all(params)
	end


end
