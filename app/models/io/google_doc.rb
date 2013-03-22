require 'google/api_client'
require 'securerandom'

=begin
	
	- abstract out authentication (use oauth token to login)
		- get a token to test with

	- write watir script to add the google script to the spreadsheet

	- throw error on dumb schemas

	- duplicate filenames

	= combine google_doc and g_doc
			- changes trigger_changes

	- remove all

=end

class GoogleDoc
	include Mongoid::Document
	self.mass_assignment_sanitizer = :strict
	include Mongoid::Timestamps
	include Mongoid::Paranoia
	
	field :filename, type: String
	field :data, type: Hash
	field :schema, type: Hash
	field :auth_tokens, type: Hash
	field :worksheet_name, type: String
	field :username, type: String
	field :password, type: String

	belongs_to :product

	attr_accessor :session
	attr_accessor :file_obj
	attr_accessor :worksheet_obj

	def initialize(params)
		@session = GoogleDrive.login(params[:username], params[:password])
		create_new_doc(params[:filename]) if params[:create_new].to_bool
		worksheet_name = params[:worksheet_name] != nil ? params[:worksheet_name] : "Sheet1"
		super({
			data: {}, 
			filename: params[:filename], 
			schema: params[:schema], 
			auth_tokens: @session.auth_tokens,
			worksheet_name: worksheet_name,
			username: params[:username],
			password: params[:password]
			})

		@file_obj = @session.spreadsheet_by_title(self.filename)
		@worksheet_obj = @file_obj.worksheet_by_title(self.worksheet_name)
		self.save!
	end

	def create_new_doc(filename)
		doc_with_script = "BLANK_WITH_SCRIPT"
		template = @session.spreadsheet_by_title(doc_with_script)
		template.duplicate(filename)
	end

	def restart_session
		@session = GoogleDrive.login(self.username, self.password)
		@file_obj = @session.spreadsheet_by_title(self.filename)
		@worksheet_obj = @file_obj.worksheet_by_title(self.worksheet_name)
	end

	def store_state
		self.update_attribute(:data, self.all_hashed)
	end

	def get_state
		self.data
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
				Trigger.trigger(self.product.id, channel, row)		# relies on Gdoc id
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
				changes[:all] 		<< curr_rows[curr_key]
				changes[:additions] << curr_rows[curr_key]
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
	def add_key(key)
		restart_session
		numkeys = @worksheet_obj.list.keys.length
		@worksheet_obj[1, numkeys+1] = key
		@worksheet_obj.save
	end

	def num_keys
		restart_session
		@worksheet_obj.list.keys.length
	end

	# creates a row with hash of key-value params
	def create_row(params)
		restart_session
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
		restart_session
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
		restart_session
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
		restart_session
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
		restart_session
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
		restart_session
		if(@worksheet_obj.nil?)
			return []
		else
			@worksheet_obj.list.to_hash_array
		end
	end

	def all_hashed
		restart_session
		if(@worksheet_obj.nil?)
			return {}
		else
			arr = @worksheet_obj.list.to_hash_array
			hsh = Hash[arr.each_with_index.map { |row, id| [id, row] }]
			return hsh
		end
	end

	def update_row(search_hash, update_hash)
		restart_session
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
		restart_session
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
		restart_session
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
		restart_session
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
