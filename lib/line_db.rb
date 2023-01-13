require_relative "file_methods"
require_relative "partitioned_array_database"
# VERSION v1.0.1-release: rem_db and add_db methods added
# VERSION v1.0.0-release
# VERSION v0.0.1 - Database creation by superfolder
class LineDB
  attr_accessor :parent_folder, :database_file_name, :linelist
  include FileMethods  
  PARENT_FOLDER = "./database/CGMFS_db"
  DATABASE_FILE_NAME = "./database/db_list.txt"
  PAD = PartitionedArrayDatabase
  
  ENDLESS_ADD = true
  HAS_CAPACITY = true
  DATABASE_SIZE = 100
  DYNAMICALLY_ALLOCATES = true


  def initialize(endless_add: ENDLESS_ADD, has_capacity: HAS_CAPACITY, db_size: DATABASE_SIZE, dynamically_allocates: DYNAMICALLY_ALLOCATES, parent_folder: PARENT_FOLDER, database_file_name: DATABASE_FILE_NAME)
    @parent_folder = parent_folder
    @database_file_name = database_file_name
    @endless_add = endless_add
    @has_capacity = has_capacity
    @db_size = db_size
    @dynamically_allocates = dynamically_allocates  
    @linelist = load_pad(parent_folder: @parent_folder)
  end

  def load_pad(parent_folder: @parent_folder || PARENT_FOLDER)
    db_linelist = read_file_lines(@database_file_name)
    db_list = {}
    db_linelist.each do |db_name|
      #puts "new pad"
      db_list[db_name] = PAD.new(database_file_name: db_name, endless_add: @endless_add, has_capacity: @has_capacity, dynamically_allocates: @dynamically_allocates, db_size: @db_size) if !parent_folder
      db_list[db_name] = PAD.new(database_file_name: "#{parent_folder}/#{db_name}", endless_add: @endless_add, has_capacity: @has_capacity, dynamically_allocates: @dynamically_allocates, db_size: @db_size) if parent_folder
    end
    db_list
  end

  def list_databases
    @linelist.keys
  end

  def reload
    @linelist = load_pad(parent_folder: @parent_folder)
  end

  def db(db_name)
    @linelist[db_name]
  end

  def load_config(config_file_name)
    
  end

  def remove_db(db_name)
    @linelist.delete(db_name)
    remove_line(db_name)
    reload
  end

  def add_db(db_name)
    write_line(db_name) if !check_file_duplicates(db_name)
    reload
  end

end 

# a = LineDB.new(parent_folder: "./database/GALLERY_db", database_file_name: "./database/db_list.txt")