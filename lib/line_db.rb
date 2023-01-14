require_relative "file_methods"
require_relative "partitioned_array_database"
# VERSION v1.0.4-release: bug fixes, new features, and tested (partitioned_array/decomposition.rb)
# VERSION v1.0.3-release: bugs fixed and tested
# VERSION v1.0.2-release: rem_db -> remove_db, bugs fixed and tested
# VERSION v1.0.1-release: rem_db and add_db methods added
# VERSION v1.0.0-release
# VERSION v0.0.1 - Database creation by superfolder
class LineDB
  attr_accessor :parent_folder, :database_folder_name, :linelist
  include FileMethods  
  PARENT_FOLDER = "./database/CGMFS_db"
  DATABASE_FOLDER_NAME = "database"
  DATABASE_FILE_NAME = "./database/db_list.txt"
  PAD = PartitionedArrayDatabase

  ENDLESS_ADD = true
  HAS_CAPACITY = true
  DATABASE_SIZE = 100
  DYNAMICALLY_ALLOCATES = true
  DATABASE_PARTITION_AMOUNT = 20

  TRAVERSE_HASH = true

  def initialize(traverse_hash: TRAVERSE_HASH, database_partition_amount: DATABASE_PARTITION_AMOUNT, database_file_name: DATABASE_FILE_NAME, endless_add: ENDLESS_ADD, has_capacity: HAS_CAPACITY, db_size: DATABASE_SIZE, dynamically_allocates: DYNAMICALLY_ALLOCATES, parent_folder: PARENT_FOLDER, database_folder_name: DATABASE_FOLDER_NAME)
    @parent_folder = parent_folder
    @database_folder_name = database_folder_name
    @database_file_name = database_file_name
    @endless_add = endless_add
    @database_partiton_amount = database_partition_amount
    @has_capacity = has_capacity
    @db_size = db_size
    @dynamically_allocates = dynamically_allocates
    @traverse_hash = traverse_hash
    @linelist = load_pad(parent_folder: @parent_folder)
  end

  def list_databases
    @linelist.keys
  end

  def [](db_name)
    @linelist[db_name]
  end

  def reload
    @linelist = load_pad(parent_folder: @parent_folder)
  end

  def db(db_name)
    @linelist[db_name]
  end

  def remove_db!(db_name)
    @linelist.delete(db_name)
    remove_line(db_name)
    remove_pad_single(db_name)
  end

  # TODO: implement rm_rf for dragonruby on windows and linux, and maybe android
  def delete_db!(db_name)    
    FileUtils.rm_rf(db(db_name).database_folder_name)#{@parent_folder}/#{db_name}")
    remove_db!(db_name)
  end

  def add_db!(db_name)
    write_line(db_name) if !check_file_duplicates(db_name)
    load_pad_single(db_name)
  end

  #### Low level methods (but we don't enforce it lol, because they can still have their uses) ####
  # private
  
  def load_pad_single(db_name, parent_folder: @parent_folder || PARENT_FOLDER)
    db_linelist = read_file_lines(@database_file_name)
    if db_linelist.include?(db_name)
      @linelist[db_name] = PAD.new(database_folder_name: db_name, endless_add: @endless_add, has_capacity: @has_capacity, dynamically_allocates: @dynamically_allocates, db_size: @db_size) if !parent_folder
      @linelist[db_name] = PAD.new(database_folder_name: "#{parent_folder}/#{db_name}", endless_add: @endless_add, has_capacity: @has_capacity, dynamically_allocates: @dynamically_allocates, db_size: @db_size) if parent_folder
    end
  end

  def remove_pad_single(db_name)
    db_linelist = read_file_lines(@database_file_name)
    if db_linelist.include?(db_name)
      @linelist.delete(db_name)
    end
  end
  # TODO: implement rm_rf for dragonruby on windows and linux, and maybe android
  def delete_pad_single(db_name)
    db_linelist = read_file_lines(@database_file_name)
    if db_linelist.include?(db_name)
      @linelist.delete(db_name)
      FileUtils.rm_rf(db(db_name).database_folder_name)#{@parent_folder}/#{db_name}")
    end
  end

  def load_pad(parent_folder: @parent_folder || PARENT_FOLDER)
    db_linelist = read_file_lines(@database_file_name)
    db_list = {}
    db_linelist.each do |db_name|
      #puts "new pad"
      db_list[db_name] = PAD.new(database_folder_name: db_name, endless_add: @endless_add, has_capacity: @has_capacity, dynamically_allocates: @dynamically_allocates, db_size: @db_size) if !parent_folder
      db_list[db_name] = PAD.new(database_folder_name: "#{parent_folder}/#{db_name}", endless_add: @endless_add, has_capacity: @has_capacity, dynamically_allocates: @dynamically_allocates, db_size: @db_size) if parent_folder
    end
    db_list
  end
end

# a = LineDB.new(parent_folder: "./database/GALLERY_db", database_file_name: "./database/db_list.txt")