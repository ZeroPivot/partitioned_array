require_relative "file_methods"
require_relative "partitioned_array_database"

# VERSION v0.0.1 - Database creation by superfolder
class LineDB
  attr_accessor :parent_folder, :database_file_name, :linelist
  include FileMethods  
  PARENT_FOLDER = "./database/CGMFS_db"
  DATABASE_FILE_NAME = "./database/db_list.txt"
  PAD = PartitionedArrayDatabase
  
  def initialize(parent_folder: PARENT_FOLDER, database_file_name: DATABASE_FILE_NAME)
    @parent_folder = parent_folder
    @database_file_name = database_file_name
    @linelist = load_pad(parent_folder: @parent_folder)
  end

  def load_pad(parent_folder: @parent_folder || PARENT_FOLDER)
    db_linelist = read_file_lines(@database_file_name)
    #puts db_linelist
    db_list = {}
    db_linelist.each do |db_name|
      db_list[db_name] = PAD.new(database_folder_name: db_name) if !parent_folder
      db_list[db_name] = PAD.new(database_folder_name: "#{parent_folder}/#{db_name}") if parent_folder
    end
    db_list
  end

  def reload
    @linelist = load_pad(parent_folder: @parent_folder)
  end

  def get_db(db_name)
    @linelist[db_name]
  end

end 
end