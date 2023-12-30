# rubocop:disable Style/FrozenStringLiteralComment
# rubocop:disable Metrics/ParameterLists
# rubocop:disable Style/NegatedIf
# rubocop:disable Style/GuardClause
# rubocop:disable Layout/LineLength
# rubocop:disable Style/MutableConstant
# rubocop:disable Style/StringLiterals

require_relative "file_methods"
require_relative "partitioned_array_database"
# VERSION v4.0.0-release: synchronized with PartitionedArray
# TODO: fully implement for DragonRuby (/lib/dr)
#################
# which decomposes to FileContextManagedPartitionedArrayManager objects;
# which decomposes to FileContextManagedPartitionedArray objects;
# which decomposes to ManagedPartitionedArray objects, which inherits from the PartitionedArray class.
# VERSION v3.0.0-release:
# NOTE: This is a major update, and IS backwards compatible with the previous versions.
# SEE managed_partitioned_array.rb and partitioned_array.rb for more information DragonRuby version and regular lib version)
# NOTE: FILES ARE ALL SYNCED WITH THE DRAGONRUBY VERSION and VICE VERSA
# VERSION: v1.2.0-release
# VERSION v1.1.7-release: cleanup
# VERSION v1.1.6-release: label_integer and label_ranges for the ManagedPartitionedArray class, wherein you can define a set of integers or ranges separated by commas
# --and with the arguments set, set a hash like {id => object}
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

# LineDB: Line Database - Create a database of PartitionedArrayDatabase objects;
class LineDB
  attr_accessor :parent_folder, :database_folder_name, :linelist, :database_file_name, :endless_add, :has_capacity, :db_size, :dynamically_allocates, :partition_amount, :traverse_hash

  include FileMethods
  PAD = PartitionedArrayDatabase

  ### Fallback Constants; a database folder and a db_list.txt file in the database folder must be present. ###
  ### db_list.txt must contain line separated sets of database names (see "lib/line_database_setup.rb") ###
  PARENT_FOLDER = "./db/CGMFS_db"
  DATABASE_FOLDER_NAME = "db"
  DATABASE_FILE_NAME = "./db/db_list.txt"

  ### Suggested Constants ###
  ENDLESS_ADD = true
  HAS_CAPACITY = true
  DATABASE_SIZE = 100
  DYNAMICALLY_ALLOCATES = true
  DATABASE_PARTITION_AMOUNT = 20
  TRAVERSE_HASH = true
  LABEL_INTEGER = false
  LABEL_RANGES = false
  ### /Suggested Constants ###

  # Initializes a new instance of the LineDB class.
  #
  # @param label_integer [Boolean] Whether to label integers.
  # @param label_ranges [Boolean] Whether to label ranges.
  # @param traverse_hash [Boolean] Whether to traverse the hash.
  # @param database_partition_amount [Integer] The number of partitions in the database.
  # @param database_file_name [String] The name of the database file.
  # @param endless_add [Boolean] Whether to allow endless adding to the database.
  # @param has_capacity [Boolean] Whether the database has a capacity.
  # @param db_size [Integer] The size of the database.
  # @param dynamically_allocates [Boolean] Whether the database dynamically allocates memory.
  # @param parent_folder [String] The parent folder of the database.
  # @param database_folder_name [String] The name of the database folder.
  def initialize(label_integer: LABEL_INTEGER, label_ranges: LABEL_RANGES, traverse_hash: TRAVERSE_HASH, database_partition_amount: DATABASE_PARTITION_AMOUNT, database_file_name: DATABASE_FILE_NAME, endless_add: ENDLESS_ADD, has_capacity: HAS_CAPACITY, db_size: DATABASE_SIZE, dynamically_allocates: DYNAMICALLY_ALLOCATES, parent_folder: PARENT_FOLDER, database_folder_name: DATABASE_FOLDER_NAME)
    @label_integer = label_integer
    @label_ranges = label_ranges
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
    @lambda_list = ->{@linelist.keys.map { |db_name| db_name }}
    @active_database = nil
    #@lambda_list_all = ->{@linelist.keys.map { |db_name| db_name }}
    #@lambda_list = ->(database_name){@linelist.keys.map { |db_name| @linelist[db_name] }}
  end

  # Adds an element to the database starting from the left hand side, and skipping over nils.
  def lhs_add

  end

  # Adds an element to the database starting from the right hand side, and skipping over nils going from left to right.
  def rhs_add

  end

  # Sets a subelement in a partition to nil.
  #
  # @param partition_number [Integer] The partition number.
  # @param subelement_index [Integer] The subelement index.
  # @return [Boolean] True if successful, false otherwise.
  def nillize_partition_subelement!(partition_number, subelement_index)
    if (@active_database)
      db[@active_database].PAD.save_partition_to_file!(partition_number)
      @data_array[partition_number][subelement_index] = nil
      return true
    else
      return false
    end
  end

  # Makes a partition and its subelements revenant.
  #
  # @param partition_number [Integer] The partition number.
  # @return [Boolean] True if successful, false otherwise.
  def revenant_partition!(partition_number)
    if (@active_database)
      db[@active_database].PAD.load_partition_from_file!(partition_number)
      return true
    else
      return false
    end
  end

  # Deletes a partition and sets all its subelements to nil.
  #
  # @param partition_number [Integer] The partition number.
  # @return [Boolean] True if successful, false otherwise.
  def kill_partition!(partition_number)
    if (@active_database)
      db[@active_database].PAD.save_partition_to_file!(partition_number)
      db[@active_database].PAD.each_with_index do |partition_id, subelement_index|
        db[@active_database].PAD.data_arr[partition_id][subelement_index] = nil
      end
      return true
    else
      return false
    end
  end

  # Sets the active database.
  #
  # @param db_name [String] The name of the database.
  def active_database=(db_name)
    @active_database = db_name
  end

  # Checks if there is an active database.
  #
  # @return [PartitionedArrayDatabase, false] The active database if exists, false otherwise.
  def active_database?
    if (@active_database)
      db[@active_database]
    else
      false
    end
  end

  # Returns a list of active databases.
  #
  # @return [Array<String>] The list of active databases.
  def list_databases
    @linelist.keys
  end

  def databases_list

  end

  # Returns a list of databases.
  #
  # @return [Array<String>] The list of databases.
  def databases
    @lambda_list.call
  end

  # Updates the list of databases.
  def update_databases
    @lambda_list = ->{@linelist.keys.map { |db_name| db_name }}
  end

  # Returns the specified databases.
  #
  # @param db_names [Array<String>] The names of the databases.
  # @return [PartitionedArrayDatabase, Array<PartitionedArrayDatabase>] The specified databases.
  def [](*db_names)
    if db_names.size > 1
      return db_names.map { |db_name| @linelist[db_name] }
    else
      return @linelist[db_names[0]]
    end
  end

  # Reloads the database.
  def reload
    @linelist = load_pad(parent_folder: @parent_folder)
  end

  # Returns the specified database.
  #
  # @param db_name [String] The name of the database.
  # @return [PartitionedArrayDatabase] The specified database.
  def db(db_name)
    @linelist[db_name]
  end

  # Removes a database.
  #
  # @param db_name [String] The name of the database.
  def remove_db!(db_name)
    @linelist.delete(db_name)
    remove_line(db_name)
    remove_pad_single(db_name)
  end

  # Deletes a database.
  #
  # @param db_name [String] The name of the database.
  def delete_db!(db_name)
    FileUtils.rm_rf(db(db_name).database_folder_name)
    remove_db!(db_name)
  end

  # Adds a database.
  #
  # @param db_name [String] The name of the database.
  def add_db!(db_name)
    write_line(db_name, @database_file_name) unless check_file_duplicates(db_name)
    load_pad_single(db_name)
  end

  #### Low level methods (but we don't enforce it lol, because they can still have their uses) ####
  # private
  def load_pad_single(db_name, parent_folder: @parent_folder || PARENT_FOLDER)
    db_linelist = read_file_lines(@database_file_name)
    if db_linelist.include?(db_name)
      @linelist[db_name] = PAD.new(label_integer: @label_integer, label_ranges: @label_ranges, traverse_hash: @traverse_hash, database_folder_name: db_name, endless_add: @endless_add, has_capacity: @has_capacity, dynamically_allocates: @dynamically_allocates, db_size: @db_size) if !parent_folder
      @linelist[db_name] = PAD.new(label_integer: @label_integer, label_ranges: @label_ranges, traverse_hash: @traverse_hash, database_folder_name: "#{parent_folder}/#{db_name}", endless_add: @endless_add, has_capacity: @has_capacity, dynamically_allocates: @dynamically_allocates, db_size: @db_size) if parent_folder
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
      db_list[db_name] = PAD.new(label_integer: @label_integer, label_ranges: @label_ranges, traverse_hash: @traverse_hash, database_folder_name: db_name, endless_add: @endless_add, has_capacity: @has_capacity, dynamically_allocates: @dynamically_allocates, db_size: @db_size) if !parent_folder
      db_list[db_name] = PAD.new(label_integer: @label_integer, label_ranges: @label_ranges, traverse_hash: @traverse_hash, database_folder_name: "#{parent_folder}/#{db_name}", endless_add: @endless_add, has_capacity: @has_capacity, dynamically_allocates: @dynamically_allocates, db_size: @db_size) if parent_folder
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

# Q: how do I resolve a merge conflict?
