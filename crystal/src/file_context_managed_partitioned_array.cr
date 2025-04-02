


require "./managed_partitioned_array"
require "json"
require "file_utils"

class FileContextManagedPartitionedArray
  property fcmpa_db_indexer_db : ManagedPartitionedArray
  property fcmpa_active_databases : Hash(String, ManagedPartitionedArray)
  property active_database : String?
  property db_file_incrementor : Int32
  property db_file_location : String
  property db_path : String
  property db_name : String
  property db_size : Int32
  property db_endless_add : Bool
  property db_has_capacity : Bool
  property fcmpa_db_indexer_name : String
  property fcmpa_db_folder_name : String
  property fcmpa_db_size : Int32
  property fcmpa_partition_amount_and_offset : Int32
  property db_partition_amount_and_offset : Int32
  property partition_addition_amount : Int32
  property db_dynamically_allocates : Bool
  property timestamp_str : String
  property traverse_hash : Bool
  property raise_on_no_db : Bool
  property db_max_capacity : (String | Int32)
  property db_partition_addition_amount : Int32
  property db_partition_archive_id : Int32
  property fcmpa_db_dynamically_allocates : Bool
  property fcmpa_db_endless_add : Bool
  property fcmpa_db_has_capacity : Bool
  property fcmpa_db_partition_addition_amount : Int32
  property fcmpa_db_max_capacity : (String | Int32)
  property fcmpa_db_partition_amount_and_offset : Int32
  property fcmpa_db_partition_archive_id : Int32
  property fcmpa_db_index_location : Int32
  property label_integer : Bool
  property label_ranges : Bool
  
  # Constants
  DB_SIZE = 20
  DB_MAX_CAPACITY = "data_arr_size"
  DB_PARTITION_AMOUNT = 9
  DB_PARTITION_OFFSET = 1
  DB_PARTITION_ADDITION_AMOUNT = 5
  DB_NAME = "fcmpa_db"
  DB_PATH = "./DB/FCMPA_DB"
  DB_HAS_CAPACITY = false
  DB_DYNAMICALLY_ALLOCATES = true
  DB_ENDLESS_ADD = true
  DB_PARTITION_ARCHIVE_ID = 0
  
  FCMPA_DB_SIZE = 20
  FCMPA_DB_ENDLESS_ADD = true
  FCMPA_DB_DYNAMICALLY_ALLOCATES = true
  FCMPA_DB_PARTITION_ADDITION_AMOUNT = 5
  FCMPA_DB_HAS_CAPACITY = false
  FCMPA_DB_INDEXER_NAME = "FCMPA_DB_INDEX"
  FCMPA_DB_FOLDER_NAME = "./DB/FCMPA"
  FCMPA_DB_MAX_CAPACITY = "data_arr_size"
  FCMPA_DB_PARTITION_ARCHIVE_ID = 0
  FCMPA_DB_PARTITION_AMOUNT = 9
  FCMPA_DB_OFFSET = 1
  FCMPA_DB_INDEX_LOCATION = 0
  
  LABEL_INTEGER = false
  LABEL_RANGES = false
  TRAVERSE_HASH = true
  DEBUG = true
  RAISE_ON_NO_DB = false
  
  def initialize(
    @raise_on_no_db = RAISE_ON_NO_DB,
    @traverse_hash = TRAVERSE_HASH,
    @db_max_capacity = DB_MAX_CAPACITY,
    @db_size = DB_SIZE,
    @db_endless_add = DB_ENDLESS_ADD,
    @db_has_capacity = DB_HAS_CAPACITY,
    @db_name = DB_NAME,
    @db_path = DB_PATH,
    @db_partition_amount_and_offset = DB_PARTITION_AMOUNT + DB_PARTITION_OFFSET,
    @db_dynamically_allocates = DB_DYNAMICALLY_ALLOCATES,
    @db_partition_addition_amount = DB_PARTITION_ADDITION_AMOUNT,
    @db_partition_archive_id = DB_PARTITION_ARCHIVE_ID,
    @fcmpa_db_indexer_name = FCMPA_DB_INDEXER_NAME,
    @fcmpa_db_folder_name = FCMPA_DB_FOLDER_NAME,
    @fcmpa_db_size = FCMPA_DB_SIZE,
    @fcmpa_db_partition_amount_and_offset = FCMPA_DB_PARTITION_AMOUNT + FCMPA_DB_OFFSET,
    @fcmpa_db_has_capacity = FCMPA_DB_HAS_CAPACITY,
    @fcmpa_db_partition_addition_amount = FCMPA_DB_PARTITION_ADDITION_AMOUNT,
    @fcmpa_db_dynamically_allocates = FCMPA_DB_DYNAMICALLY_ALLOCATES,
    @fcmpa_db_endless_add = FCMPA_DB_ENDLESS_ADD,
    @fcmpa_db_max_capacity = FCMPA_DB_MAX_CAPACITY,
    @fcmpa_db_partition_archive_id = FCMPA_DB_PARTITION_ARCHIVE_ID,
    @fcmpa_db_index_location = FCMPA_DB_INDEX_LOCATION,
    @label_integer = LABEL_INTEGER,
    @label_ranges = LABEL_RANGES
  )
    @fcmpa_db_indexer_db = ManagedPartitionedArray.new
    @fcmpa_active_databases = {} of String => ManagedPartitionedArray
    @active_database = nil
    @db_file_incrementor = 0
    @db_file_location = ""
    @timestamp_str = new_timestamp
    
    load_indexer_db!
  end
  
  def debug(say)
    puts say if DEBUG
  end
  
  def new_timestamp
    Time.now.to_s("%Y-%m-%d-%H-%M-%S")
  end
  
  def load_indexer_db!
    @fcmpa_db_indexer_db = ManagedPartitionedArray.new(
      endless_add: @fcmpa_db_endless_add,
      dynamically_allocates: @fcmpa_db_dynamically_allocates,
      has_capacity: @fcmpa_db_has_capacity,
      partition_addition_amount: @fcmpa_db_partition_addition_amount,
      partition_amount_and_offset: @fcmpa_db_partition_amount_and_offset,
      db_size: @fcmpa_db_size,
      db_name: @fcmpa_db_indexer_name,
      db_path: @fcmpa_db_folder_name,
      max_capacity: @fcmpa_db_max_capacity,
      partition_archive_id: @fcmpa_db_partition_archive_id
    )
    @fcmpa_db_indexer_db.allocate
    begin
      @fcmpa_db_indexer_db.load_everything_from_files!
    rescue
      @fcmpa_db_indexer_db.save_everything_to_files!
    end
  end
  
  # Create a new database to be stored and ran by the FCMPA
  def new_database(database_index_name_str, fcmpa_db_index_location = @fcmpa_db_index_location, db_name = @db_name, db_path = @db_path, initial_autosave = true)
    db_name_str = database_index_name_str
    
    # Returns false if the database already exists
    if db_index = @fcmpa_db_indexer_db.get(fcmpa_db_index_location)
      if db_index["db_name"]?
        return false
      end
    end
    
    path = "#{db_path}_#{db_name_str}"
    
    @fcmpa_db_indexer_db.set(fcmpa_db_index_location) do |entry|
      entry[db_name_str] = {
        "db_path" => path,
        "db_name" => "#{db_name}_#{db_name_str}",
        "db_table_name" => [] of String
      }
    end
    @fcmpa_db_indexer_db.save_everything_to_files!
    
    # db indexer variable takes the responsibility of maintaining these databases via key names
    temp = ManagedPartitionedArray.new(
      endless_add: @db_endless_add,
      dynamically_allocates: @db_dynamically_allocates,
      has_capacity: @db_has_capacity,
      max_capacity: @db_max_capacity,
      partition_addition_amount: @db_partition_addition_amount,
      partition_amount_and_offset: @db_partition_amount_and_offset,
      db_size: @db_size,
      db_name: "#{db_name}_#{db_name_str}",
      db_path: path,
      partition_archive_id: @db_partition_archive_id,
      label_integer: @label_integer,
      label_ranges: @label_ranges
    )
    temp.allocate
    @fcmpa_active_databases[db_name_str] = temp
    temp.save_everything_to_files! if initial_autosave
    
    # returns true if the database was created
    true
  end
  
  # left off making it so that the database auto allocates and auto loads and saves on call
  def start_database!(database_index_name, raise_on_no_db = false, db_name = @db_name, db_path = @db_path)
    db_index = @fcmpa_db_indexer_db.get(@fcmpa_db_index_location)
    if !db_index || !db_index[database_index_name]?
      raise "Database not found" if raise_on_no_db
      
      new_database(database_index_name, db_name: db_name, db_path: db_path)
    else
      db_name = db_index[database_index_name]["db_name"].as_s
      db_path = db_index[database_index_name]["db_path"].as_s
      
      @fcmpa_active_databases[database_index_name] = ManagedPartitionedArray.new(
        endless_add: @db_endless_add,
        dynamically_allocates: @db_dynamically_allocates,
        has_capacity: @db_has_capacity,
        max_capacity: @db_max_capacity,
        partition_addition_amount: @db_partition_addition_amount,
        partition_amount_and_offset: @db_partition_amount_and_offset,
        db_size: @db_size,
        db_name: db_name,
        db_path: db_path,
        partition_archive_id: @db_partition_archive_id,
        label_integer: @label_integer,
        label_ranges: @label_ranges
      )
      begin
        @fcmpa_active_databases[database_index_name].load_everything_from_files!
        # debug "database loaded"
      rescue
        @fcmpa_active_databases[database_index_name].allocate
        @fcmpa_active_databases[database_index_name].save_everything_to_files!
        # debug "new database saved"
      end
      # debug "saved everything to files"
    end
    @fcmpa_active_databases[database_index_name]
  end
end