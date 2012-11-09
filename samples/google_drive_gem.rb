require "rubygems"
require "google_drive"
require 'highline/import'


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

#finds Price column, adds a row, and inserts "hello"
budget.list.push({"Price" => "Hello"})
budget.save()