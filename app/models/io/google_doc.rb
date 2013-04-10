require 'google/api_client'
require 'securerandom'
require 'base64'

=begin

	- share the ujumbo-created-spreadsheet with user
	- add support for multiple worksheets 

=end

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
	field :key, type: String
	field :trailing_key, type: String

	validates_presence_of :filename
	validates_presence_of :worksheets

	belongs_to :product
	belongs_to :user

	validates :user, associated: true

	attr_accessor :session
	attr_accessor :file_obj
	attr_accessor :use_existing_doc

	after_initialize :after_initialize_hook
	def after_initialize_hook
		raise "Google Doc must have a user" if self.user.nil?
		restart_session
		if (GoogleDoc.where(:id => self.id).exists?)
			raise "The user must have a GoogleCredential set" if self.user.google_credential.token.nil?
			restart_session_if_necessary
			hookup_to_gdrive
		end

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
		self.google_doc_worksheets.each do |worksheet|
			worksheet.validate_schema
			worksheet.set_worksheet_object
			worksheet.setup_schema
			worksheet.store_state
		end
		@file_obj.worksheet_by_title("Sheet1").delete if self.google_doc_worksheets.length > 0  # delete the default worksheet tab
		set_trigger
		self.save!
	end

	def convert_key(key)
		key[13..key.length]
	end

	def create_new_doc
		doc_with_script = "BLANK_WITH_SCRIPT"
		template = @session.spreadsheet_by_title(doc_with_script)
		template.duplicate(self.filename)
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
		@file_obj = @session.spreadsheet_by_title(self.filename) #TODO find by key
		key = @file_obj.key
		if key.length == 23
			self.key = Base64.encode64(key)[0...-2]
		else
			self.key = key
		end
		self.trailing_key = convert_key(self.key)
		self.save!
	end

	def set_trigger
		doc_url = @file_obj.human_url
		set_trigger_with_watir google_doc_url: doc_url, username: "hello", password: "movefastandbreakthings"
	end

	def set_trigger_with_watir(params)
		browser = Watir::Browser.new 

		# navigate to the google doc page
		browser.goto params[:google_doc_url]

		# login on the way
		browser.text_field(:id => 'Email').when_present.set(params[:username])
		browser.text_field(:id => 'Passwd').when_present.set(params[:password])
		browser.button(:id => 'signIn').click

		# go to the editor
		editor_url = /"maestro_script_editor_uri":"(.*)","maestro_new_project/.match(browser.html)[1].gsub("\\/", "/")
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
		browser.close
	end

end
