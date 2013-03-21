require 'google/api_client'
require 'securerandom'

=begin
	
	- abstract out authentication (use oauth token to login)
		- get a token to test with

	- change initialize() for create_new

	- write watir script to add the google script to the spreadsheet

	- throw error on dumb schemas

	- duplicate filenames

	= combine google_doc and g_doc
			- changes trigger_changes

	- remove all

=end

class GoogleDoc
=begin
	include Mongoid::Document
	self.mass_assignment_sanitizer = :strict
	include Mongoid::Timestamps
	include Mongoid::Paranoia
	
	field :filename, type: String
	field :data, type: String
	field :schema, type: Hash
	belongs_to :product
=end
	attr_accessor :session
	attr_accessor :filename
	attr_accessor :worksheet_name
	attr_accessor :file_obj
	attr_accessor :worksheet_obj
	attr_accessor :auth_tokens

	def initialize(params)
		auth_token = params[:auth_token]
		username = params[:username]
		password = params[:password]
		create_new = params[:create_new].to_bool
		@filename = params[:filename]
		@worksheet_name = params[:worksheet_name]

		#@session = GoogleDrive.login_with_oauth(auth_token)
		@session = GoogleDrive.login(username, password)
		create_new_doc(params) if create_new

		@auth_tokens = @session.auth_tokens
		@file_obj = @session.spreadsheet_by_title(@filename)
		@worksheet_obj = @file_obj.worksheet_by_title(@worksheet_name)
	end

	def create_new_doc(schema)
		doc_with_script = "BLANK_WITH_SCRIPT"
		template = @session.spreadsheet_by_title(doc_with_script)
		template.duplicate(@filename)

		GDoc.create(
			name: @filename,
			schema: schema
		)
	end

	def copy_file(f_obj, new_title)
		f_obj.duplicate(new_title)
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
end
