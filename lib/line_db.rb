# rubocop:disable Style/FrozenStringLiteralComment
# rubocop:disable Metrics/ParameterLists
# rubocop:disable Style/NegatedIf
# rubocop:disable Style/GuardClause
# rubocop:disable Layout/LineLength
# rubocop:disable Style/MutableConstant
# rubocop:disable Style/StringLiterals

require_relative "file_methods"
require_relative "partitioned_array_database"
# LineDB: Line Database - Create a database of PartitionedArrayDatabase objects;
# which decomposes to FileContextManagedPartitionedArrayManager objects;
# which decomposes to FileContextManagedPartitionedArray objects;
# which decomposes to ManagedPartitionedArray objects, which inherits from the PartitionedArray class.
# VERSION v1.1.5-release: [] functions, which allows for selecting multiple databases
# VERSION v1.1.4-release: added traverse_hash constant and variable, added []; synchronized with file_context_managed_partitioned_array_manager.rb, partitioned_array_database.rb, and line_reader.rb--and managed_partitioned_array.rb
# VERSION v1.1.3-release: documentation in comments
# VERSION v1.1.2-release: fixed redundancy in the code
# VERSION v1.1.0-release: bug fixes, new features, and tested (partitioned_array/decomposition.rb)
# VERSION v1.0.3-release: bugs fixed and tested
# VERSION v1.0.2-release: rem_db -> remove_db, bugs fixed and tested
# VERSION v1.0.1-release: rem_db and add_db methods added
# VERSION v1.0.0-release
# VERSION v0.0.1 - Database creation by superfolder
class LineDB
  attr_accessor :parent_folder, :database_folder_name, :linelist, :database_file_name, :endless_add, :has_capacity, :db_size, :dynamically_allocates, :partition_amount, :traverse_hash

  include FileMethods
  PAD = PartitionedArrayDatabase

  ### Fallback Constants; a database folder and a db_list.txt file in the database folder must be present. ###
  ### db_list.txt must contain line separated sets of database names (see "lib/line_database_setup.rb") ###
  PARENT_FOLDER = "./database/CGMFS_db"
  DATABASE_FOLDER_NAME = "database"
  DATABASE_FILE_NAME = "./database/db_list.txt"

  ### Suggested Constants ###
  ENDLESS_ADD = true
  HAS_CAPACITY = true
  DATABASE_SIZE = 100
  DYNAMICALLY_ALLOCATES = true
  DATABASE_PARTITION_AMOUNT = 20
  TRAVERSE_HASH = true
  ### /Suggested Constants ###

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

  # List of active databases
  def list_databases
    @linelist.keys
  end

  def [](*db_names)
    #@linelist[db_name]
    if db_names.size > 1
      return db_names.map { |db_name|{ db_name => @linelist[db_name] }}
    else
      return @linelist[db_names[0]]
    end
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
    FileUtils.rm_rf(db(db_name).database_folder_name)
    remove_db!(db_name)
  end

  def add_db!(db_name)
    write_line(db_name) unless check_file_duplicates(db_name)
    load_pad_single(db_name)
  end

  #### Low level methods (but we don't enforce it lol, because they can still have their uses) ####
  # private

  def load_pad_single(db_name, parent_folder: @parent_folder || PARENT_FOLDER)
    db_linelist = read_file_lines(@database_file_name)
    if db_linelist.include?(db_name)
      @linelist[db_name] = PAD.new(traverse_hash: @traverse_hash, database_folder_name: db_name, endless_add: @endless_add, has_capacity: @has_capacity, dynamically_allocates: @dynamically_allocates, db_size: @db_size) if !parent_folder
      @linelist[db_name] = PAD.new(traverse_hash: @traverse_hash, database_folder_name: "#{parent_folder}/#{db_name}", endless_add: @endless_add, has_capacity: @has_capacity, dynamically_allocates: @dynamically_allocates, db_size: @db_size) if parent_folder
    end
  end

  def remove_pad_single(db_name)
    @linelist.delete(db_name)
  end

  # TODO: implement rm_rf for dragonruby on windows and linux, and maybe android
  def delete_pad_single(db_name)
    db_linelist = read_file_lines(@database_file_name)
    if db_linelist.include?(db_name)
      @linelist.delete(db_name)
      FileUtils.rm_rf(db(db_name).database_folder_name)
    end
  end

  def load_pad(parent_folder: @parent_folder || PARENT_FOLDER)
    db_linelist = read_file_lines(@database_file_name)
    db_list = {}
    db_linelist.each do |db_name|
      db_list[db_name] = PAD.new(traverse_hash: @traverse_hash, database_folder_name: db_name, endless_add: @endless_add, has_capacity: @has_capacity, dynamically_allocates: @dynamically_allocates, db_size: @db_size) if !parent_folder
      db_list[db_name] = PAD.new(traverse_hash: @traverse_hash, database_folder_name: "#{parent_folder}/#{db_name}", endless_add: @endless_add, has_capacity: @has_capacity, dynamically_allocates: @dynamically_allocates, db_size: @db_size) if parent_folder
    end
    db_list
  end
end

# rubocop:enable Style/StringLiterals
# rubocop:enable Style/MutableConstant
# rubocop:enable Layout/LineLength
# rubocop:enable Style/FrozenStringLiteralComment
# rubocop:enable Style/GuardClause
# rubocop:enable Style/NegatedIf
# rubocop:enable Metrics/ParameterLists
