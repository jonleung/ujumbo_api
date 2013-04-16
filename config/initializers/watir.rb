$browser = Watir::Browser.new

username = "ujumboplatform"
password = "movefastandbreakthings"

browser = $browser
#browser.goto "https://www.google.com/a/ujumbo.com/ServiceLogin?service=writely&passive=1209600&continue=https://docs.google.com/a/ujumbo.com/%23&followup=https://docs.google.com/a/ujumbo.com/&ltmpl=homepage"
browser.goto "https://accounts.google.com/ServiceLogin?service=wise&passive=1209600&continue=https://drive.google.com/%23my-drive&followup=https://drive.google.com/&ltmpl=drive"
browser.text_field(:id => 'Email').when_present.set(username)
browser.text_field(:id => 'Passwd').when_present.set(password)
browser.button(:id => 'signIn').click