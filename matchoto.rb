
require 'sqlite3'
require 'fileutils'

Shoes.app(title: "matchoto") do

  @imported_list = list_box

  @control_flow = flow do
    style height: 20
    @imported_list.remove()

    @reset_button = button "RESET" do
      delete_db_if_exists
    end

    @view_db_button = button "view database" do
      view_db
    end

    @select_btn = button "Select folder" do
      @working_folder = ask_open_folder
      if !folder_is_empty(@working_folder)
        alert("Selected folder contains previous photos. \nPlease format before starting a new job")
      else
        delete_db_if_exists
    	  create_database
        @select_btn.hide()
        @new_code_button.show()
        @import_button.show()
        @view_flow.caption time+" --> Selected working folder path: "+@working_folder+"\n" , stroke: "#fff" , size: "12"
      end
  	end

    @import_button = button "Import TextFile" do
      import_products
    end

    @new_code_button = button "New code" do
      write_to_db
      @product_code = ask("Enter product code:")
      @view_flow.caption time+" --> Current product code: "+@product_code+".\n" , stroke: "#fff" , size: "12"
      @finish_button.show()
    end

    @finish_button = button "Finish" do
      @rename_button.show()
      write_to_db
      @view_flow.caption time+" --> Job is finished.\n" , stroke: "#fff" , size: "12"
      backup_db
    end

    @rename_button = button "Rename" do
      @final_photos_folder = ask_open_folder
      if folder_is_empty(@final_photos_folder)
        alert("Selected folder is empty")
      else
        rename
      end
    end



    def existing_files
      results = @db.execute "select filename from pairs"
      results.flatten
    end

    def write_to_db
      files = Dir.entries(@working_folder)
      files = files - ['.', '..']
      if !files.empty?
        debug ('writing to db')
        (files - existing_files).each do |file|
          @db.execute "insert into pairs (filename, product_code) values ('#{file}', '#{@product_code}')"
          # @db.execute "insert into pairs (filename, product_code) values ('#{file}', '#{@product_code}__B')"
          @view_flow.caption time+ " Inserted pair: #{file} --> #{@product_code}\n" , stroke: "#fff" , size: "12"
        end
      end
    end

    def create_database
      # @db = SQLite3::Database.new "#{@folder}/default.db"
      @db = SQLite3::Database.new "default.db"
      @db.execute "create table pairs (t1key INTEGER PRIMARY KEY, filename TEXT, product_code TEXT)"
      @reset_button.show()
      @view_db_button.show()
    end

    def delete_db_if_exists
      if db_exists
        if confirm ("Starting a new job, will erase any previous work. \nAre you sure?")
          FileUtils.rm('default.db')
          hide_on_reset
        end
      end
    end

    def rename
      FileUtils.mkdir @final_photos_folder+"/OK"
      files = Dir.entries(@final_photos_folder)-['.','..','OK']
      if !files.empty?
        @db = SQLite3::Database.new 'default.db'
        @db.execute("select filename , product_code from pairs").each do |file|
          if files.include?(file[0])
            FileUtils.cp(@final_photos_folder+'/'+file[0] , @final_photos_folder+'/OK/'+file[0])
            FileUtils.mv(@final_photos_folder+'/OK/'+file[0] , @final_photos_folder+'/OK/'+file[1]+'.jpg')
            @view_flow.caption time+" "+file[0] +" renamed to " + "OK/"+file[1]+".jpg\n" , stroke: "#fff" , size: "12"
          end
        end
      end
    end

    def view_db
      if db_exists
        window title: "database contents" do
          @db = SQLite3::Database.new 'default.db'
          @db.execute("select filename , product_code from pairs").each do |file|
            @db_view = caption (file[0] +" > "+file[1]+"\n")
          end
        end
      end
    end


    def hide_on_reset
      @view_flow.clear()
      @select_btn.show()
      @import_button.hide()
      @view_db_button.hide()
      @new_code_button.hide()
      @finish_button.hide()
      @rename_button.hide()
      @reset_button.hide()
      @imported_list.remove()
      @view_flow.caption time+" --> Job reseted\n" , stroke: "#fff" , size: "12"
    end

    def backup_db
      FileUtils.cp('default.db' , '.')
    end

    def time
      time = Time.now
      time.strftime("%H:%M:%S")
    end

    def folder_is_empty(folder)
      files = Dir.entries(folder)- ['.', '..']
      files.empty?
    end

    def db_exists()
      files = Dir.entries('.')
      files.include?('default.db')
    end

    def import_products
      @imported_list.remove()
      filename = ask_open_file
      @imported_products = File.read(filename).split(" ")
      @view_flow.caption time+" --> "+@imported_products.size.to_s+" products imported" , stroke: "#fff" , size: "12"
      @control_flow.append do
        @imported_list = list_box items: @imported_products
        @imported_list.change do
          @finish_button.show()
          write_to_db
          @product_code = @imported_list.text
          @view_flow.caption time+" --> Current product code: "+@product_code+".\n" , stroke: "#fff" , size: "12"
        end
      end
    end


  end

  @view_flow = stack do
    caption "..."
  end

end
