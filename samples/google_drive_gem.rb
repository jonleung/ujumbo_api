require "rubygems"
require "google_drive"
require 'highline/import'

# github docs: 	https://github.com/gimite/google-drive-ruby
# api docs: 	http://gimite.net/doc/google-drive-ruby/index.html

puts "username:"
username = gets

password = ask("Enter password: ") { |q| q.echo = false }

session = GoogleDrive.login(username, password)

#prints all the files
for file in session.files
	puts file.title
end

#opens big ass spreadsheet and prints all of its lines
spreadsheet = session.spreadsheet_by_title("Big Ass Spreadsheet")
budget = spreadsheet.worksheet_by_title("Budget")

budget.list.each{ |row| puts row["Price"] }

#finds Price column, adds a row, and inserts "hello"
budget.list.push({"Price" => "Hello"})
budget.save()