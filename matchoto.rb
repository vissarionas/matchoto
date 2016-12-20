require 'sqlite3'
require 'fileutils'

Shoes.app(title: "matchoto", width: 1000, height: 500, resizable: false) do

  @all_files = []
  @current_val = nil
  @edit_val = ""
  @imported_list = nil
  @select_btn = nil
  @product_code = nil
  @rename_folder = nil
  @db_view = nil
  @time = Time.new.inspect


  @control_flow = flow do
    button "view database" do
      view_db
    end

    button "New Job" do
      if confirm ("Starting a new job, will erase any previous work. \nAre you sure?")
        place_ok_folder
        delete_db_if_exists
        @select_btn.show()
        @report_view=caption @time+" --> Created folders 'OK' and 'renamed'. Deleted previous database\n"
      end
    end

    @select_btn = button "Select folder" do
      @working_folder = ask_open_folder
      if !check_folder(@working_folder)
        alert("Selected folder contains previous photos. \nPlease format before starting a new job")
        @report_view = caption @time+" --> Working folder is not empty. Please empty working folder\n"
      else
        delete_db_if_exists
    	  create_database
        @select_btn.hide()
        @report_view = caption @time+" --> Previous database deleted. New database created. Selected working folder is "+@working_folder+"\n"
      end
  	end

    # button "Import TextFile" do
    # 	import_txt
    # end

    button "New code" do
      write_to_db
      @product_code = ask("Enter product code:")
      @select_btn.hide
      @report_view = caption @time+" --> Product code = "+@product_code+".\n"
    end

    # button "Edit code" do
    #   @product_code << ask("Edit your code:")
    # end

    button "Finish" do
      write_to_db
      @report_view = caption @time+" --> Job is finished."
    end

    button "Rename" do
      rename
    end
  end

  @caption_flow = flow do
   @report_view
  end

  def place_ok_folder
    files = Dir.entries(".")
    if files.include?('OK')
      FileUtils.rm_rf('OK')
    end
    Dir.mkdir "./OK"
    Dir.mkdir 'OK/renamed'
  end

	# def display_current_val
  #   flow top: 50, left: 0 do
  #     caption "Current code:", stroke: "#fff"
  #     @current_val.remove unless @current_val == nil
  #     @current_val = caption @product_code, stroke: "#fff"
  #   end
  # end

  def existing_files
    results = @db.execute "select filename from pairs"
    results.flatten
  end

  def write_to_db
    files = Dir.entries(@working_folder)
    files = files - ['.', '..', 'default.db']
    if !files.empty?
      debug ('writing to db')
      (files - existing_files).each do |file|
        @db.execute "insert into pairs (filename, product_code) values ('#{file}', '#{@product_code}')"
        # @db.execute "insert into pairs (filename, product_code) values ('#{file}', '#{@product_code}__B')"
      end
    end
  end

  def create_database
    # @db = SQLite3::Database.new "#{@folder}/default.db"
    @db = SQLite3::Database.new "default.db"
    @db.execute "create table pairs (t1key INTEGER PRIMARY KEY, filename TEXT, product_code TEXT)"
  end

  def delete_db_if_exists
    files = Dir.entries(".")
    if files.include?('default.db')
      File.delete('default.db')
    end
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

  def check_folder(folder)
    files = Dir.entries(folder)- ['.', '..']
    files.empty?
  end

  def rename
    files = Dir.entries('OK')-['.','..','renamed']
    if !files.empty?
      @db = SQLite3::Database.new 'default.db'
      @db.execute("select filename , product_code from pairs").each do |file|
        if files.include?(file[0])
          FileUtils.cp('OK/'+file[0] , 'OK/renamed/'+file[0])
          FileUtils.mv('OK/renamed/'+file[0] , 'OK/renamed/'+file[1]+'.jpg')
          @report_view = caption "OK/renamed/"+file[0] +"renamed to" + "OK/renamed/"+file[1]+".jpg"
        end
      end
    else
      alert ("Folder 'OK' is empty. \nNothing to rename.")
    end
  end

  def view_db
    window title: "database contents" do
      files = Dir.entries('.')
      if files.include?('default.db')
        @db = SQLite3::Database.new 'default.db'
        @db.execute("select filename , product_code from pairs").each do |file|
          @db_view = caption (file[0] +" > "+file[1]+"\n")
        end
      else
        @db_view = caption "empty/no database"
      end
    end
  end
end
