require 'sqlite3'

Shoes.app(title: "abubaca", width: 800, height: 800, resizable: false) do

  @all_files = []
  @current_val = nil
  @edit_val = ""
  @imported_list = nil

  @select_btn = button("Select folder") do
    @folder = ask_open_folder
	  delete_db_if_exists
	  create_database
	end

  button "Import TextFile" do
  	import_txt
  end

  button "New code" do
    write_to_db
    @product_code = ask("Enter product code:")
    display_current_val
    @select_btn.remove
  end

  button "Edit code" do
    @product_code << ask("Edit your code:")
  end

  button "Finish" do
    write_to_db
    # File.rename(@folder + '/' + @all_files[index].first, @folder + '/' + code + '.jpg')
  end

  button "Rename" do
    @this_db = SQLite3::Database.new ask_open_file
    @chosen_folder = ask_open_folder
    @rename_folder = Dir.mkdir @chosen_folder + "/renamed"
    @this_db.execute("select filename from pairs").each do |file|
      debug file
    end
  end

	def display_current_val
    flow top: 50, left: 0 do
      caption "Current code:", stroke: "#fff"
      @current_val.remove unless @current_val == nil
      @current_val = caption @product_code, stroke: "#fff"
    end
  end

  def existing_files
    results = @db.execute "select filename from pairs"
    results.flatten
  end

  def write_to_db
    files = Dir.entries(@folder)
    files = files - ['.', '..', 'default.db']
    if !files.empty?
      (files - existing_files).each do |file|
        @db.execute "insert into pairs (filename, product_code) values ('#{file}', '#{@product_code}__A')"
        @db.execute "insert into pairs (filename, product_code) values ('#{file}', '#{@product_code}__B')"
      end
    end
  end

  def create_database
    @db = SQLite3::Database.new "#{@folder}/default.db"
    @db.execute "create table pairs (t1key INTEGER PRIMARY KEY, filename TEXT, product_code TEXT)"
  end

  def delete_db_if_exists
    files = Dir.entries(@folder)
    File.delete(@folder + '/default.db') if files.include?('default.db')
  end

  def import_txt
  	filename = ask_open_file
  	imported = File.read(filename).split(" ")
  	@imported_list = list_box items: imported
  	@imported_list.change do
  		@product_code = @imported_list.text
  		display_current_val
  	end
  end


end
