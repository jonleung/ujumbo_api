require 'watir-webdriver'
require 'ruby-debug'
browser = Watir::Browser.new

browser.goto 'https://script.google.com/a/macros/ujumbo.com/d/M7tvy78dGUyowbbMHw17-Y9LyW7547XVE/edit?uiv=2&tz=America/New_York&docTitle=Gdocs_pipe_25&csid=td1TBZQOkpw0SXbPIBuRzhQ.06483039675329959494.1567001993424957037&mid=ACjPJvG-eHYMQwNo-1XDYUyghbZqxTLya7w0BRkPiRKq7rsWJU13DNa__CrFdjuQuQB2r1Px3bxwo4WSKZbClYL1PTn6tpzE593OUIc1C9X1oNClCpg&hl=en_US'

browser.text_field(:id => 'Email').when_present.set("hello")
browser.text_field(:id => 'Passwd').when_present.set("movefastandbreakthings")
browser.button(:id => 'signIn').click

browser.div(:id, "triggersButton").when_present.click
puts browser.div(:class, "gwt-Anchor add-trigger")
browser.link(:class, "gwt-Anchor add-trigger").when_present.click
trigger_selects = browser.div(:class, "trigger-row").selects(:class, "gwt-ListBox listbox")
on_edit = trigger_selects.find { |select| select.include?("On edit") }
on_edit.select("On edit")

browser.div(:class, "controls").button(:text => "Save").click


#puts browser.div(:id => "macros-resources-menu").attribute_list
#browser.div("aria-activedescendant", ":1d").when_present.click