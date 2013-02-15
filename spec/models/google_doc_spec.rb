require 'spec_helper'

describe Io::GoogleDoc do 
	
	username = "hello@ujumbo.com"
	password = "movefastandbreakthings"
	filename = "gdocs_test"
	worksheet_name = "Sheet 1"

	filename2 = "changes_test"
	worksheet_name2 = "Sheet1"
	
	before(:all) do
		@test_doc = Io::GoogleDoc.new(username, password, filename, worksheet_name)
		@change_test_doc = Io::GoogleDoc.new(username, password, filename2, worksheet_name2)
		initial_row = { "Animals" => "Fox", "Games" => "Halo"}
		@test_doc.create_row(initial_row)
	end

	it "should add a row" do
		num_rows_before_add = @test_doc.all.count
		row = { "Keys" => 2, "Houses" => 1}
		@test_doc.create_row(row)
		num_rows_after_add = @test_doc.all.count
		num_rows_after_add.should == (num_rows_before_add + 1)
	end

	it "should append to existing key" do
		row = { "Yolo" => 1 }
		@test_doc.create_row(row)
		row = { "Yolo" => 2 }
		@test_doc.create_row(row)
		a = 1
		a.should == 1
	end

	it "should remove a row" do
		num_rows_before_add = @test_doc.all.count
		row = { "Goodbye" => "Hello" }
		params = { "Goodbye" => "Hello" }
		@test_doc.create_row(row)
		@test_doc.delete(params)
		num_rows_after_add = @test_doc.all.count
		num_rows_after_add.should == (num_rows_before_add)
	end

	it "should add a key" do
		num_keys_before_add = @test_doc.num_keys
		@test_doc.add_key("People")
		num_keys_after_add = @test_doc.num_keys
		num_keys_after_add.should == (num_keys_before_add + 1)
	end

	it "should update a row" do
		row = { "Updater" => -1 , "Shoes" => "Feet" }
		@test_doc.create_row(row)
		update = { "Updater" => 100 }
		@test_doc.update(row, update)["Updater"].should == "100"
	end

	it "should replace a row" do
		row = { "Chairs" => "Comfortable", "Trees" => "Green", "Posters" => "Decorative"}
		@test_doc.create_row(row)
		replaced = @test_doc.replace({"Chairs" => "Comfortable"}, {"Trees" => "Purple"})
		results = []
		results << replaced["Chairs"]
		results << replaced["Trees"]
		results << replaced["Posters"]

		results.should == ["", "Purple", ""]

	end

	it "should read a row" do
		row =  { "Jazz" => "Miles Davis" }
		row2 = { "Jazz" => "John Coltrane" }
		@test_doc.create_row(row)
		@test_doc.create_row(row2)
		@test_doc.where({ "Jazz" => "Miles Davis" }).length.should == 1

	end

	it "should store state without crashing" do
		@test_doc.store_state
	end

	it "should print out the state" do
		state = @test_doc.get_state
		state.length.should > 0
	end

	it "adding a new row: it should print out the change" do
		@change_test_doc.store_state
		row = { "Animals" => "Change", "Games" => "Walking Dead" }
		@change_test_doc.create_row(row)
		change = @change_test_doc.get_changes
		change.should == [{ "Animals" => "Change", "Games" => "Walking Dead" }]
		@change_test_doc.clear_sheet
	end

	it "modifying a cell: it should print out the changed row" do
		row = { "Animals" => "Panda", "Games" => "Walking Dead" }
		@change_test_doc.create_row(row)
		@change_test_doc.store_state

		update = { "Games" => "Tetris" }
		@change_test_doc.update(row, update)

		change = @change_test_doc.get_changes
		change.should == [{ "Animals" => "Panda", "Games" => "Tetris" }]

		@change_test_doc.clear_sheet
	end

	#it "should authenticate to google docs" do
	#	arr = @test_doc.authenticate
	#	puts arr
	#end

	#it "should print the changes list" do
	#	@test_doc.get_updates
	#end

	after(:all) do
		@test_doc.clear_sheet
		@change_test_doc.clear_sheet
	end

end