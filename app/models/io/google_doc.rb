require 'google/api_client'

=begin
	
creating a new spreadsheet: duplicate one with the google script in it
	- code some way to store the schema ('types') of the column-names
=end

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
		@worksheet_obj = @file_obj.worksheet_by_title(@worksheet_name)
	end

	def self.create_new_doc(username, password, filename)
		doc_with_script = "BLANK_WITH_SCRIPT"
		sesh = GoogleDrive.login(username, password)
		file_to_copy = sesh.spreadsheet_by_title(doc_with_script)
		self.copy_file(file_to_copy, filename)
	end

	def self.copy_file(f_obj, new_title)
		f_obj.duplicate(new_title)
	end

	def copy_doc(new_title)
		@file_obj.duplicate(new_title)
	end

	def delete_history
		GDoc.delete_all(name: @worksheet_name)
	end

	def store_state
		data = self.all_hashed
		serial_data = Marshal.dump(data)
		GDoc.create(
			name: @worksheet_name,
			data: serial_data
		)
	end

	def get_state
		gdoc = GDoc.where(name: @worksheet_name).last
		data = Marshal.load(gdoc.data)
		return data
	end

	def get_changes
		old_rows = self.get_state
		curr_rows = self.all_hashed
		changes = []
		
		curr_rows.keys.each do |curr_key|
			old_rows.keys.each do |old_key|
				# check existing rows for changes
				if curr_key == old_key
					dif = curr_rows[curr_key].diff(old_rows[old_key])
					if dif != {}
						# adds the entire row to the changes list
						changes << curr_rows[curr_key]
						# to add the specific change, use: changes << dif
					end
				end
			end
		end

		# if there's a new row
		curr_rows.keys.each do |curr_key|
			if !old_rows.keys.include?(curr_key)
				changes << curr_rows[curr_key]
			end
		end
		store_state
		return changes
	end

	def get_updates
		#response = HTTParty.get('https://docs.google.com/feeds/hello%40ujumbo.com/private/changes')
		#puts response.body, response.code, response.message, response.headers.inspect
	end
	# adds a key (first row of spreadsheet)
	def add_key(key)
		numkeys = @worksheet_obj.list.keys.length
		@worksheet_obj[1, numkeys+1] = key
		@worksheet_obj.save
	end

	def num_keys
		@worksheet_obj.list.keys.length
	end

	# creates a row with hash of key-value params
	def create_row(params)
		GoogleDrive.restore_session(@auth_tokens)
		# add the keys if they don't exist
		params.each do | key, value |
			if(!@worksheet_obj.list.keys.include?(key))
				add_key(key)
			end
		end
		# save key changes
		if(@worksheet_obj.dirty?)
			@worksheet_obj.synchronize
		end
		#push the new row
		@worksheet_obj.list.push(params)
		@worksheet_obj.save
	end

	def where(params)
		matches = []
		rows = @worksheet_obj.list
		params.each do | param_key, param_val |
			rows.each do | row |
				if( row[param_key].to_s == param_val.to_s)
					matches << row.to_hash
				end
			end
		end
		return matches
	end

	def find(params)
		return where(params)
	end

	def delete(params)
		rows = @worksheet_obj.list
		params.each do | param_key, param_val |
			rows.each do | row |
				if( row[param_key].to_s == param_val.to_s)
					row.clear
					@worksheet_obj.save
					return
				end
			end
		end
		
	end

	def delete_all(params)
		rows = @worksheet_obj.list
		params.each do | param_key, param_val |
			rows.each do | row |
				if( row[param_key].to_s == param_val.to_s)
					row.clear
				end
			end
		end
		@worksheet_obj.save
	end

	def clear_sheet
		rows = @worksheet_obj.list
		rows.each do | row |
			row.clear
		end
		@worksheet_obj.save
		@worksheet_obj.list.keys = []
		@worksheet_obj.save
	end

	# returns all the rows as an array of hashes
	def all
		if(@worksheet_obj.nil?)
			return []
		else
			@worksheet_obj.list.to_hash_array
		end
	end

	def all_hashed
		if(@worksheet_obj.nil?)
			return {}
		else
			arr = @worksheet_obj.list.to_hash_array
			hsh = Hash[arr.each_with_index.map { |row, id| [id, row] }]
			return hsh
		end
	end

	def update(search_hash, update_hash)
		rows = @worksheet_obj.list
		search_hash.each do | param_key, param_val |
			rows.each do | row |
				if( row[param_key].to_s == param_val.to_s)
					row.update(update_hash)
					@worksheet_obj.save
					return row.to_hash
				end
			end
		end
	end

	def update_all(search_hash, update_hash)
		updated_rows = []
		rows = @worksheet_obj.list
		search_hash.each do | param_key, param_val |
			rows.each do | row |
				if( row[param_key].to_s == param_val.to_s)
					row.update(update_hash)
					@worksheet_obj.save
					updated_rows << row.to_hash
				end
			end
		end
		return updated_rows
	end

	def replace(search_hash, replace_hash)
		rows = @worksheet_obj.list
		search_hash.each do | param_key, param_val |
			rows.each do | row |
				if( row[param_key].to_s == param_val.to_s)
					row.clear
					@worksheet_obj.save
					row.update(replace_hash)
					@worksheet_obj.save
					return row.to_hash
				end
			end
		end
	end

	def replace_all(search_hash, replace_hash)
		replaced_rows = []
		rows = @worksheet_obj.list
		search_hash.each do | param_key, param_val |
			rows.each do | row |
				if( row[param_key].to_s == param_val.to_s)
					row.clear
					@worksheet_obj.save
					row.update(replace_hash)
					@worksheet_obj.save
					replaced_rows << row.to_hash
				end
			end
		end
		return replaced_rows
	end


	def authenticate
		cid = "140001700804.apps.googleusercontent.com"
		csecret = "kmVxHyY_fvexlqaEovRfIyb7"
		ruri = "https://localhost/oauth2callback"
		client = Google::APIClient.new
		drive = client.discovered_api('drive', 'v2')

		client.authorization.client_id = cid
		client.authorization.client_secret = csecret
		client.authorization.scope = "https://www.googleapis.com/drive/"
		client.authorization.redirect_uri = ruri
		
		uri = client.authorization.authorization_uri
		client.authorization.code = '....'
		client.authorization.fetch_access_token!

		arr = Array.new
		result = client.execute(
			:api_method => drive.changes.list,
			:parameters => { }
			)
		arr.concat(result.items)
		return arr
	end
end
