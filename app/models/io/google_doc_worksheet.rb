class GoogleDocWorksheet

	include Mongoid::Document
	self.mass_assignment_sanitizer = :strict
	include Mongoid::Timestamps
	include Mongoid::Paranoia
	embedded_in :google_doc

	field :data, type: Hash
	field :schema, type: Hash
	field :name, type: String
	attr_accessor :worksheet_obj

	validates_presence_of :schema

	def set_worksheet_object
		self.name ||= self.id
		if @worksheet_obj == nil
			@worksheet_obj = self.google_doc.file_obj.worksheet_by_title(self.name)
			if @worksheet_obj == nil
				@worksheet_obj = self.google_doc.file_obj.add_worksheet(self.name)
			end
		end
	end

	def reset_worksheet_obj
		@worksheet_obj = self.google_doc.file_obj.worksheet_by_title(self.name)
	end

	def setup_schema
		self.schema.keys.each do |attribute|
			self.add_column_key(attribute) unless column_key_exists(attribute)
		end
	end

	def validate_schema
		self.schema.each do |key, value|
			unless value.in?(GoogleDoc.valid_types)
				return false
			end
		end
		return true
	end

	def store_state
		self.update_attribute(:data, self.all_hashed)
	end

	def get_state
		self.data
	end

	def rightmost_key
		@worksheet_obj[1, num_keys]
	end

	def column_key_exists(key)
		@worksheet_obj.list.keys.include?(key)
	end

	def key_index(key)
		(1..@worksheet_obj.num_cols).detect {|i| @worksheet_obj[1,i] == key }
	end

	def triggering_column_names
		self.schema.select{ |column_name, type| type == :triggering_column }.keys
	end

	def trigger_changes
		base_channel = "google_docs:spreadsheet:row"
		changes = get_changes
		changes.each do |status, rows|
			rows.each do |row|
				case status
				when :additions
					channel = "#{base_channel}:create"
				when :deletions
					channel = "#{base_channel}:destroy"
				when :updates
					channel = "#{base_channel}:update"
				end
				triggering_column_names.each do |col_name|
					if row[col_name].downcase == "send"
						update_row(row, { col_name => "SENT"} )
						Trigger.trigger(self.google_doc.product_id, channel, row.merge(google_doc_id: self.google_doc.id, sheet_name: self.name)) if channel.present?
					end
				end
			end
		end
	end

	def get_changes
		old_rows = self.get_state
		curr_rows = self.all_hashed
		changes = { all: [], additions: [], deletions: [], updates: [] }
		curr_rows.keys.each do |curr_key|
			old_rows.keys.each do |old_key|
				# check existing rows for changes
				if curr_key == old_key
					dif = curr_rows[curr_key].diff(old_rows[old_key])
					if dif != {}
						# adds the entire row to the changes list
						changes[:all] 		<< curr_rows[curr_key]
						changes[:updates]	<< curr_rows[curr_key] if curr_rows[curr_key] != {}
						# to add the specific change, use: changes << dif
					end
				end
			end
		end

		# if there's a new row
		curr_rows.keys.each do |curr_key|
			if !old_rows.keys.include?(curr_key)
				if !curr_rows[curr_key].values.all?(&:empty?)  # check if it's an empty row
					changes[:all] 		<< curr_rows[curr_key]
					changes[:additions] << curr_rows[curr_key]
				end
			end
		end


		# if a row was deleted
		old_rows.keys.each do |old_key|
			if !curr_rows.keys.include?(old_key)
				changes[:all]		<< {deleted: old_rows[old_key]}
				changes[:deletions] << {deleted: old_rows[old_key]}
			end
		end

		store_state
		return changes
	end

	# adds a key (first row of spreadsheet)
	def add_column_key(key)
		self.google_doc.restart_session_if_necessary #TODO do we actually need to do these?
		reset_worksheet_obj if @worksheet_obj == nil
		@worksheet_obj[1, num_keys+1] = key
		@worksheet_obj.save
	end

	def delete_column_key(key)
		self.google_doc.restart_session_if_necessary
		reset_worksheet_obj if @worksheet_obj == nil
		if column_key_exists(key)
			index = key_index(key) # finds index of key
			@worksheet_obj.list.each { |row| row[key] = "" }  # deletes value in key's column from every row
			@worksheet_obj[1,index] = ""					  # deletes the top row value
		end
		@worksheet_obj.save
	end

	def num_keys
		self.google_doc.restart_session_if_necessary
		reset_worksheet_obj if @worksheet_obj == nil
		@worksheet_obj.list.keys.length
	end

	# creates a row with hash of key-value params
	def create_row(params)
		self.google_doc.restart_session_if_necessary
		reset_worksheet_obj if @worksheet_obj == nil
		# add the keys if they don't exist
		params.each do | key, value |
			if(!@worksheet_obj.list.keys.include?(key))
				add_column_key(key)
			end
		end
		# save key changes
		if(@worksheet_obj.dirty?)
			@worksheet_obj.synchronize
		end
		#push the new row
		new_row = @worksheet_obj.list.push(params)
		@worksheet_obj.save
		return new_row
	end

	def where(params)
		self.google_doc.restart_session_if_necessary
		reset_worksheet_obj if @worksheet_obj == nil
		matches = []
		rows = @worksheet_obj.list
		params.each do | param_key, param_val |
			rows.each do | row |
				if( row[param_key].to_s == param_val.to_s)
					matches << row.to_hash
				debugger
				elsif PhoneHelper.standardize(row[param_key].to_s) == PhoneHelper.standardize(param_val.to_s) # if you're searching by phone number, standardize it
					matches << row.to_hash
				end
			end
		end
		return matches
	end

	def find(params)
		return where(params)
	end

	# def find_row_by_phone(params)
	# 	self.google_doc.restart_session_if_necessary
	# 	reset_worksheet_obj if @worksheet_obj == nil
	# 	matches = []
	# 	rows = @worksheet_obj.list
	# 	params.each do | param_key, param_val |
	# 		rows.each do | row |
	# 			if( PhoneHelper.standardize(row[param_key].to_s) == PhoneHelper.standardize(param_val.to_s))
	# 				matches << row.to_hash
	# 			end
	# 		end
	# 	end
	# 	return matches
	# end

	def delete(params)
		self.google_doc.restart_session_if_necessary
		reset_worksheet_obj if @worksheet_obj == nil
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
		self.google_doc.restart_session_if_necessary
		reset_worksheet_obj if @worksheet_obj == nil
		rows = @worksheet_obj.list
		deleted_rows = {}
		params.each do | param_key, param_val |
			rows.each_with_index do | row, index |
				if( row[param_key].to_s == param_val.to_s)
					deleted_rows[index.to_s] = row
					row.clear
				end
			end
		end
		@worksheet_obj.save
		return deleted_rows
	end

	def clear_sheet
		self.google_doc.restart_session_if_necessary
		reset_worksheet_obj if @worksheet_obj == nil
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
		self.google_doc.restart_session_if_necessary
		reset_worksheet_obj if @worksheet_obj == nil
		if(@worksheet_obj.nil?)
			return []
		else
			@worksheet_obj.list.to_hash_array
		end
	end

	def all_hashed
		self.google_doc.restart_session_if_necessary
		self.set_worksheet_object
		if(@worksheet_obj.nil?)
			return {}
		else
			arr = @worksheet_obj.list.to_hash_array
			hsh = Hash[arr.each_with_index.map { |row, id| [id.to_s, row] }]
			return hsh
		end
	end

	def update_row(search_hash, update_hash)
		self.google_doc.restart_session_if_necessary
		reset_worksheet_obj if @worksheet_obj == nil
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
		self.google_doc.restart_session_if_necessary
		reset_worksheet_obj if @worksheet_obj == nil
		updated_rows = {}
		rows = @worksheet_obj.list
		search_hash.each do | param_key, param_val |
			rows.each_with_index do | row, index |
				if( row[param_key].to_s == param_val.to_s)
					row.update(update_hash)
					@worksheet_obj.save
					updated_rows[index.to_s] = row.to_hash
				end
			end
		end
		return updated_rows
	end

	def replace(search_hash, replace_hash)
		self.google_doc.restart_session_if_necessary
		reset_worksheet_obj if @worksheet_obj == nil
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
		self.google_doc.restart_session_if_necessary
		reset_worksheet_obj if @worksheet_obj == nil
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

end