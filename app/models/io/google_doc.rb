module Io
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
end
