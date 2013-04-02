require 'watir-webdriver'

def set_trigger_with_watir(params)
	browser = Watir::Browser.new 

	# navigate to the google doc page
	browser.goto params[:google_doc_url]

	# login on the way
	browser.text_field(:id => 'Email').when_present.set(params[:username])
	browser.text_field(:id => 'Passwd').when_present.set(params[:password])
	browser.button(:id => 'signIn').click

	editor_url = /"maestro_script_editor_uri":"(.*)","maestro_new_project/.match(browser.html)[1].gsub("\\/", "/")
	browser.goto editor_url

	# find the link to the script editor
	# sleep 10
	# puts browser.html
	# look for 'maestro'

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

url = 'https://docs.google.com/a/ujumbo.com/spreadsheet/ccc?key=0AnM0GJSzYzdKdDhadUZ3X0tOQmJOTkJwSkZKUG5rSXc#gid=0'
set_trigger_with_watir google_doc_url: url, username: "hello", password: "movefastandbreakthings"