require 'google/api_client'
require 'securerandom'
require 'base64'

class GoogleDoc
	
	def self.valid_types
		[
			:first_name,
			:last_name,
			:phone,
			:email,
			:date,
			:address,
			:text,
			:triggering_column
		]
	end

	include Mongoid::Document
	self.mass_assignment_sanitizer = :strict
	include Mongoid::Timestamps
	include Mongoid::Paranoia

	embeds_many :google_doc_worksheets, store_as: "worksheets"
	
	field :filename, type: String
	field :auth_tokens, type: Hash
	field :gdoc_key, type: String
	field :trailing_key, type: String
	field :url, type: String

	validates_presence_of :filename
	validates_presence_of :worksheets

	belongs_to :product
	belongs_to :user

	validates :user, associated: true

	attr_accessor :session
	attr_accessor :file_obj
	attr_accessor :use_existing_doc
	attr_accessor :url

	after_initialize :after_initialize_hook
	def after_initialize_hook
		restart_session

		if (GoogleDoc.where(:id => self.id).exists?)
			raise "The user must have a GoogleCredential set" if self.user.google_credential.token.nil?
			restart_session_if_necessary
			hookup_to_gdrive
		end
		save!
		#if self.use_existing_doc
			#then make the GDrive Hookups
			#hookup_to_gdrive
		#end

	end

	after_create :after_create_hook
	def after_create_hook
		restart_session_if_necessary
		create_new_doc
		hookup_to_gdrive
		self.url = @file_obj.human_url
		self.google_doc_worksheets.each do |worksheet|
			worksheet.validate_schema
			worksheet.set_worksheet_object
			worksheet.setup_schema
			worksheet.store_state
		end
		#@file_obj.worksheet_by_title("Sheet1").delete if self.google_doc_worksheets.length > 0  # delete the default worksheet tab
		self.save!
	end

	def convert_key(key)
		key[13..key.length]
	end

	def create_new_doc
		#template_doc = "BLANK_WITH_SCRIPT"
		template_doc = "MVP_TEMPLATE"
		ujumbo_session = GoogleDrive.login("hello@ujumbo.com", "movefastandbreakthings")
		template = ujumbo_session.spreadsheet_by_title(template_doc)
		new_doc  = template.duplicate(self.filename)
		set_trigger(new_doc.human_url)
		if self.user.email != "hello@ujumbo.com"
			new_doc.acl.push({scope_type: "user", scope: self.user.email, role: "writer"})  # change to 'owner' once we use a .gmail
		end
	end

	def restart_session_if_necessary
		if Time.now > Time.at(user.google_credential.expires_at)
			restart_session
		end
	end

	def restart_session
		user.google_credential.refresh
		token = self.user.google_credential.token
		@session = GoogleDrive.login_with_oauth(token)
	end

	def hookup_to_gdrive
		@file_obj1 = @session.spreadsheet_by_title(self.filename) #TODO find by key
		@file_obj2 = @session.spreadsheet_by_title(self.filename) #TODO find by key
		@file_obj = @session.spreadsheet_by_title(self.filename) #TODO find by key

		key = @file_obj.key
		if key.length == 23
			self.gdoc_key = Base64.encode64(key)[0...-2]
		else
			self.gdoc_key = key
		end
		self.trailing_key = convert_key(self.gdoc_key)
		self.save!
	end

	def set_trigger(url)
		set_trigger_with_watir google_doc_url: url, username: "hello", password: "movefastandbreakthings"
	end

	def set_trigger_with_watir(params)
		browser = $browser

		begin
			browser.url
		rescue
			$browser = Watir::Browser.new
			browser = $browser

			username = "hello"
			password = "movefastandbreakthings"

			browser = $browser
			browser.goto "https://www.google.com/a/ujumbo.com/ServiceLogin?service=writely&passive=1209600&continue=https://docs.google.com/a/ujumbo.com/%23&followup=https://docs.google.com/a/ujumbo.com/&ltmpl=homepage"
			browser.text_field(:id => 'Email').when_present.set(username)
			browser.text_field(:id => 'Passwd').when_present.set(password)
			browser.button(:id => 'signIn').click
		end

		# navigate to the google doc page
		browser.goto params[:google_doc_url]

		debugger

		# go to the editor
		editor_url = /"maestro_script_editor_uri":"(.*)","maestro_new_project/.match(browser.html)[1].gsub("\\/", "/")
		puts "EDITOR URL: " + editor_url
		browser.goto editor_url

		browser.div(:id, "triggersButton").when_present.click
		
		# click the add trigger link
		browser.link(:class, "gwt-Anchor add-trigger").when_present.click
		
		# get the dropdown-menu objects
		trigger_dropdowns = browser.div(:class, "trigger-row").selects(:class, "gwt-ListBox listbox")
		
		# find the dropdown containing on edit, click, and save
		on_edit_dropdown = trigger_dropdowns.find { |dropdown| dropdown.include?("On edit") }
		on_edit_dropdown.select("On edit")
		browser.div(:class, "controls").button(:text => "Save").click
	end

end
