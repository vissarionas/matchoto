require 'sqlite3'

Shoes.app do

  @all_files = []
  @all_codes = []
  @current_val = nil
  @edit_val = ""


  @select_btn = button("Select folder") do
    @folder = ask_open_folder
    delete_db_if_exists
    create_database
  end

  button "New code" do
    write_to_db
    @product_code = ask("Enter product code:")
    display_current_val
    @select_btn.hide
  end

  button "Edit code" do
    @product_code << ask("Edit your code:")
    display_current_val
  end

  button "Finish" do
    write_to_db
    # File.rename(@folder + '/' + @all_files[index].first, @folder + '/' + code + '.jpg')
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
        @db.execute "insert into pairs (filename, product_code) values ('#{file}', '#{@product_code}')"
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

end
