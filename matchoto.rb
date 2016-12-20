require 'sqlite3'

<<<<<<< HEAD
Shoes.app(title: "matchoto", width: 1000, height: 600, resizable: false) do
=======
Shoes.app(title: "abubaca",
   width: 1000, height: 500, resizable: false) do
>>>>>>> 3d54be548cd7949baa2ca4553c334227f1164aed

  @all_files = []
  @current_val = nil
  @edit_val = ""
  @imported_list = nil
<<<<<<< HEAD
  @select_btn = nil
  @product_code = nil


  button " New Job" do
    delete_db_if_exists
    @select_btn.show()
  end

  @select_btn = button "Select folder" do
    @working_folder = ask_open_folder
    if !check_folder(@working_folder)
      alert('Selected folder contains previous photos. Please format before starting a new job')
    else
      delete_db_if_exists
  	  create_database
      @select_btn.hide()
      debug(@working_folder)
    end
	end

  # button "Import TextFile" do
  # 	import_txt
  # end

  button "New code" do
    write_to_db
    @product_code = ask("Enter product code:")
    display_current_val
    @select_btn.hide
  end

  # button "Edit code" do
  #   @product_code << ask("Edit your code:")
  # end

  button "Finish" do
    write_to_db
    # File.rename(@folder + '/' + @all_files[index].first, @folder + '/' + code + '.jpg')
  end

  button "Rename" do
    @db = SQLite3::Database.new 'default.db'
    @chosen_folder = ask_open_folder
    @rename_folder = Dir.mkdir @chosen_folder + "/renamed"
    @db.execute("select filename from pairs").each do |file|
      debug file
    end
  end

=======

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
	  	move(100 , 100)
	    write_to_db
	    # File.rename(@folder + '/' + @all_files[index].first, @folder + '/' + code + '.jpg')
	  end
	
>>>>>>> 3d54be548cd7949baa2ca4553c334227f1164aed
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
<<<<<<< HEAD
    files = Dir.entries(@working_folder)
    files = files - ['.', '..', 'default.db']
    if !files.empty?
      debug ('writing to db')
      (files - existing_files).each do |file|
        @db.execute "insert into pairs (filename, product_code) values ('#{file}', '#{@product_code}')"
        # @db.execute "insert into pairs (filename, product_code) values ('#{file}', '#{@product_code}__B')"
=======
    files = Dir.entries(@folder)
    files = files - ['.', '..', 'default.db']
    if !files.empty?
      (files - existing_files).each do |file|
        @db.execute "insert into pairs (filename, product_code) values ('#{file}', '#{@product_code}__A')"
        @db.execute "insert into pairs (filename, product_code) values ('#{file}', '#{@product_code}__B')"
>>>>>>> 3d54be548cd7949baa2ca4553c334227f1164aed
      end
    end
  end

  def create_database
<<<<<<< HEAD
    # @db = SQLite3::Database.new "#{@folder}/default.db"
    @db = SQLite3::Database.new "default.db"
=======
    @db = SQLite3::Database.new "#{@folder}/default.db"
>>>>>>> 3d54be548cd7949baa2ca4553c334227f1164aed
    @db.execute "create table pairs (t1key INTEGER PRIMARY KEY, filename TEXT, product_code TEXT)"
  end

  def delete_db_if_exists
<<<<<<< HEAD
    files = Dir.entries(".")
    if files.include?('default.db')
      if confirm('Delete current database?')
        File.delete('default.db')
      end
    end
=======
    files = Dir.entries(@folder)
    File.delete(@folder + '/default.db') if files.include?('default.db')
>>>>>>> 3d54be548cd7949baa2ca4553c334227f1164aed
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

<<<<<<< HEAD
  def check_folder(folder)
    files = Dir.entries(folder)- ['.', '..']
    files.empty?
  end
=======
>>>>>>> 3d54be548cd7949baa2ca4553c334227f1164aed

end
