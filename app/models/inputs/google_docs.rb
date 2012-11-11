#url or spreadsheet name
#login info for google user

#row by row data into a hash
# contact when updated

module Inputs
	class GoogleDocs 

		#returns list of all the user's filenames
		def get_all_filenames(username, password)
			#session = GoogleDrive.login(username, password)
			file_list = []
			for file in session.files
				file_list.push(file.title)
			end
			return file_list
		end

		def create_spreadsheet(username, password, doc_name)
			google_doc = GoogleDoc.new(username, password, doc_name, doc_name)
			return google_doc
		end

		
	end
end
