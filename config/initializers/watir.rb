$browser = Watir::Browser.new

username = "hello"
password = "movefastandbreakthings"

browser = $browser
browser.goto "https://www.google.com/a/ujumbo.com/ServiceLogin?service=writely&passive=1209600&continue=https://docs.google.com/a/ujumbo.com/%23&followup=https://docs.google.com/a/ujumbo.com/&ltmpl=homepage"
browser.text_field(:id => 'Email').when_present.set(username)
browser.text_field(:id => 'Passwd').when_present.set(password)
browser.button(:id => 'signIn').click