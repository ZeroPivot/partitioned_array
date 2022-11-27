require_relative 'managed_partitioned_array'

# VERSION v0.2.0a 
# Refining before field testing
class FileContextManagedPartitionedArray
  attr_accessor :fcmpa_db_indexer_db, :fcmpa_active_databases, :fcmpa_db_indexer_path, :fcmpa_db_indexer_name, :fcmpa_db_size, :fcmpa_partition_amount_amd_offset
  
  # DB_SIZE > PARTITION_AMOUNT
  PARTITION_AMOUNT = 9 # The initial, + 1
  FCMPA_PARTITION_AMOUNT = 9
  FCMPA_OFFSET = 1
  OFFSET = 1 # This came with the math, but you can just state the PARTITION_AMOUNT in total and not worry about the offset in the end
  DB_SIZE = 20 # Caveat: The DB_SIZE is the total # of partitions, but you subtract it by one since the first partition is 0, in code. that is, it is from 0 to DB_SIZE-1, but DB_SIZE is then the max allocated DB size
  FCMPA_DB_SIZE = 20
  PARTITION_ARCHIVE_ID = 0
  DEFAULT_PATH = "./DB_TEST" # default fallback/write to current path
  DEBUGGING = false
  PAUSE_DEBUG = false
  #DB_NAME = 'partitioned_array_slice'
  PARTITION_ADDITION_AMOUNT = 5
  MAX_CAPACITY = "data_arr_size" # : :data_arr_size; a keyword to add to the array until its full with no buffer additions
  HAS_CAPACITY = true # if false, then the max_capacity is ignored and at_capacity? raises if @has_capacity == false
  DYNAMICALLY_ALLOCATES = true
  ENDLESS_ADD = false
  FCMPA_DB_INDEXER_NAME = "FCMPA_DB_INDEX"
  FCMPA_DB_FOLDER_NAME = "./DB/FCMPA"
  DB_NAME = "fcmpa_db"
  DB_PATH = "./DB/FCMPA"
  DB_HAS_CAPACITY = true
  DB_DYNAMICALLY_ALLOCATES = true
  DB_ENDLESS_ADD = true
  FCMPA_DB_INDEX_LOCATION = 0

  def initialize(partition_addition_amount: PARTITION_ADDITION_AMOUNT, db_size: DB_SIZE, db_endless_add: DB_ENDLESS_ADD, db_has_capacity: DB_HAS_CAPACITY, db_name: DB_NAME, db_path: DB_PATH, new_index: true, fcmpa_db_indexer_name: FCMPA_DB_INDEXER_NAME, fcmpa_db_folder_name: FCMPA_DB_FOLDER_NAME, fcmpa_db_size: FCMPA_DB_SIZE, fcmpa_partition_amount_and_offset: FCMPA_PARTITION_AMOUNT + FCMPA_OFFSET, db_partition_amount_and_offset: PARTITION_AMOUNT + OFFSET)
    @fcmpa_partition_amount_and_offset = fcmpa_partition_amount_and_offset
    @db_partition_amount_and_offset =  db_partition_amount_and_offset
    @fcmpa_db_size = fcmpa_db_size
    @partition_addition_amount = partition_addition_amount
    @fcmpa_db_indexer_name = fcmpa_db_indexer_name
    @fcmpa_db_folder_name = fcmpa_db_folder_name
    @db_has_capacity = db_has_capacity
    @db_endless_add = db_endless_add
    @db_size = db_size
    @db_path = db_path
    @db_name = db_name
    @db_dynamically_allocates = DYNAMICALLY_ALLOCATES
    @fcmpa_db_indexer_db = ManagedPartitionedArray.new(endless_add: @db_endless_add,
                                                       dynamically_allocates: @db_dynamically_allocates,
                                                       has_capacity: @db_has_capacity,
                                                       partition_addition_amount: @partition_addition_amount,
                                                       partition_amount_and_offset: @fcmpa_partition_amount_and_offset,
                                                       db_size: @fcmpa_db_size,
                                                       db_name: @fcmpa_db_indexer_name,
                                                       db_path: @fcmpa_db_folder_name)

    @fcmpa_db_indexer_db.allocate
    @fcmpa_db_indexer_db.load_everything_from_files! if !new_index
    @fcmpa_db_indexer_db.save_everything_to_files! if new_index
    @db_file_location = 0
    @db_file_incrementor = 0    
    @fcmpa_active_databases = {}
    
    @timestamp_str = Time.now.to_i.to_s
  end


  def new_database(database_index_name_str: String,
     dynamically_allocates: true,
      has_capacity: false,
       partition_amount_amd_offset: @partition_amount_and_offset,
        db_size: @db_size,
         db_path: @db_path, db_name: @db_name)
    timestamp_str = @timestamp_str # the string to give uniqueness to each database file context
    db_name_str = database_index_name_str
    @fcmpa_db_indexer_db.set(FCMPA_DB_INDEX_LOCATION) do |entry|
      entry[db_name_str] = {"db_path" => db_path, "db_name" => db_name+"_"+timestamp_str, "active" => true}
    end
    @fcmpa_db_indexer_db.save_everything_to_files!
    #@db_file_incrementor += 1   
    


    temp = ManagedPartitionedArray.new(endless_add: @db_endless_add,
                                       dynamically_allocates: @db_dynamically_allocates,
                                       has_capacity: @db_has_capacity,
                                       partition_addition_amount: @partition_addition_amount,
                                       partition_amount_and_offset: @db_partition_amount_and_offset,
                                       db_size: @db_size,
                                       db_name: @db_name+"_"+timestamp_str,
                                       db_path: @db_path)
 


    temp.allocate
    @fcmpa_active_databases[db_name_str] = temp
    temp.save_everything_to_files!
    return temp

  
  
  end
  
  def delete_database_from_index!(database_index_name)
    @fcmpa_db_indexer_db.set(0) do |entry|
      entry.delete(database_index_name)
    end
    @fcmpa_db_indexer_db.save_everything_to_files!
  end
    
  def add_database_to_index!(database_index_name, database_path, database_name)
    #timestamp_str = @timestamp_str # the string to give uniqueness to each database file context
    @fcmpa_db_indexer_db.set(0) do |entry|
      entry[database_index_name] = {"db_path" => database_path, "db_name" => database_name, "active" => true}
    end
    @fcmpa_db_indexer_db.save_everything_to_files!
  end

  def db(database_index_name = @active_database)
    @fcmpa_active_databases[database_index_name]
  end
  
  def set_active_database(database_index_name)
    @active_database = database_index_name
  end


  def stop_database!(database_index_name)
    @fcmpa_db_indexer_db.set(0) do |entry|
      entry[database_index_name]["active"] = false
    end
    @fcmpa_db_indexer_db.save_everything_to_files!
  end


  def start_database!(database_index_name)
    @fcmpa_active_databases[database_index_name] = @fcmpa_active_databases[database_index_name].load_everything_from_files!
    @fcmpa_db_indexer_db.set(0) do |entry|
      entry[database_index_name]["active"] = true
    end
    return @fcmpa_active_databases[database_index_name]
  end

  def start_databases!
    @fcmpa_db_indexer_db.each do |entry|
      entry.each do |key, value|
        temp = ManagedPartitionedArray.new(endless_add: @db_endless_add,
                                           dynamically_allocates: @db_dynamically_allocates,
                                           has_capacity: @db_has_capacity,
                                           partition_addition_amount: @partition_addition_amount,
                                           partition_amount_and_offset: @fcmpa_partition_amount_and_offset,
                                           db_size: @db_size,
                                           db_name: value["db_name"],
                                           db_path: value["db_path"])
        @fcmpa_db_indexer.set(0) do |entry|
          entry[key]["active"] = true
        end

                                           
        temp.load_everything_from_files!
        @fcmpa_active_databases[key] = temp
      end      
    end
    return @fcmpa_active_databases

  end

  def stop_databases!
    @fcmpa_active_databases.each do |key, value|
      @fcmpa_active_databases[key] = nil
    end

  end

  def load_active_databases!
    @fcmpa_db_indexer_db.each do |entry|
      entry.each do |key, value|
        if value["active"]
          temp = ManagedPartitionedArray.new(endless_add: @db_endless_add,
                                             dynamically_allocates: @db_dynamically_allocates,
                                             has_capacity: @db_has_capacity,
                                             partition_addition_amount: @partition_addition_amount,
                                             partition_amount_and_offset: @fcmpa_partition_amount_and_offset,
                                             db_size: @fcmpa_db_size,
                                             db_name: value["db_name"],
                                             db_path: value["db_path"])
          temp.load_everything_from_files!
          @fcmpa_active_databases[key] = temp
        end
      end
    end
    return @fcmpa_active_databases
  end


  def save_database!(database_index_name)
    @fcmpa_active_databases[database_index_name].save_everything_to_files!
  end

  def save_databases!
    @fcmpa_active_databases.each do |key, value|
      @fcmpa_active_databases[key].save_everything_to_files!
    end
  end

  def load_database!(database_index_name)  
    start_database!(database_index_name)
  end

  def load_databases!
    @fcmpa_active_databases.each do |key, value|
      start_database!(@fcmpa_active_databases[key])
    end

  end

  def get_databases_list
     @fcmpa_active_databases.keys
  end

  def set_new_file_archive(database_index_name, save: true)
    temp = @fcmpa_active_databases[database_index_name]
    temp = temp.archive_and_new_db!
    @fcmpa_active_databases[database_index_name] = temp
  
    #temp = db(database_index_name)

  end


end


#
#
test = FileContextManagedPartitionedArray.new
#test.new_database(database_index_name_str: "test", db_path: "./DB", db_name: "test")
#test.new_database(database_index_name_str: "test2", db_path: "./DB", db_name: "test2")
#test.db("test").set(0) do |entry|
#  entry["test"] = "test"
#end
#test.db("test").save_everything_to_files!

#puts test.db("test").get(0, hash: true)

#test.db("test2").set(1) do |entry|
#  entry["test2"] = "test2"
#end

#test.db("test2").save_everything_to_files!

#puts test.db("test2").get(1, hash: true)
#puts test.db("test2").get(1, hash: true)

# create 200 new databases


  test.new_database(database_index_name_str: "test", db_path: "./DB/slices", db_name: "test")
test.new_database(database_index_name_str: "test2", db_path: "./DB/slices", db_name: "test2")
test.set_new_file_archive("test")
test.save_database!("test")
test.save_database!("test2")