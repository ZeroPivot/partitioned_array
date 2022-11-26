require_relative 'managed_partitioned_array'

class FileContextManagedPartitionedArray
  attr_accessor :endless_add, :range_arr, :rel_arr, :db_size, :data_arr, :partition_amount_and_offset, :db_path, :db_name, :max_capacity, :has_capacity, :latest_id, :partition_archive_id, :max_partition_archive_id, :db_name_with_no_archive

  # DB_SIZE > PARTITION_AMOUNT
  PARTITION_AMOUNT = 9 # The initial, + 1
  OFFSET = 1 # This came with the math, but you can just state the PARTITION_AMOUNT in total and not worry about the offset in the end
  DB_SIZE = 20 # Caveat: The DB_SIZE is the total # of partitions, but you subtract it by one since the first partition is 0, in code. that is, it is from 0 to DB_SIZE-1, but DB_SIZE is then the max allocated DB size
  PARTITION_ARCHIVE_ID = 0
  DEFAULT_PATH = "./DB_TEST" # default fallback/write to current path
  DEBUGGING = false
  PAUSE_DEBUG = false
  DB_NAME = 'partitioned_array_slice'
  PARTITION_ADDITION_AMOUNT = 5
  MAX_CAPACITY = "data_arr_size" # : :data_arr_size; a keyword to add to the array until its full with no buffer additions
  HAS_CAPACITY = true # if false, then the max_capacity is ignored and at_capacity? raises if @has_capacity == false
  DYNAMICALLY_ALLOCATES = true
  ENDLESS_ADD = false
    
  def initialize(new_index: true, db_indexer_path: "./DB/FCMPA_DB_INDEX", db_indexer_name: "FCMPA_DB")
    
    @fcmpa_db_indexer_path = "./DB/FCMPA_DB_INDEX"
    @fcmpa_db_indexer_name = "fcmpa_db"
    @fcmpa_db_indexer_db = ManagedPartitionedArray.new(endless_add: true,
                                                    dynamically_allocates: true,
                                                     has_capacity: false,
                                                      partition_amount_and_offset: PARTITION_AMOUNT + OFFSET,
                                                        db_size: DB_SIZE,
                                                         db_name: @fcmpa_db_indexer_name,
                                                          db_path: @fcmpa_db_indexer_path)
    @fcmpa_db_indexer_db.allocate
    @fcmpa_db_indexer_db.load_everything_from_files! if !new_index
    @fcmpa_db_indexer_db.save_everything_to_files! if new_index
    @db_file_location = 0
    @db_file_incrementor = 0    
    @fcmpa_active_databases = {}
  end


  def new_database(database_index_name_str: String,
     dynamically_allocates: true,
      has_capacity: false,
       partition_amount_amd_offset: PARTITION_AMOUNT + OFFSET,
        db_size: DB_SIZE,
         db_path: DEFAULT_PATH, db_name: DB_NAME)
    timestamp_str = Time.now.to_i.to_s
    db_name_str = database_index_name_str
    @fcmpa_db_indexer_db.set(@db_file_location) do |entry|
      entry[db_name_str] = {"db_path" => db_path+"_"+timestamp_str, "db_name" => db_name+"_"+timestamp_str}
    end
    @fcmpa_db_indexer_db.save_everything_to_files!
    @db_file_incrementor += 1
    

    temp = ManagedPartitionedArray.new(endless_add: true,
    dynamically_allocates: true,
      has_capacity: false,
        partition_amount_and_offset: PARTITION_AMOUNT + OFFSET,
          db_size: DB_SIZE,
            db_name: db_name+"_"+timestamp_str,
              db_path: db_path+"_"+timestamp_str)
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
    timestamp_str = Time.now.to_i.to_s
    @fcmpa_db_indexer_db.set(0) do |entry|
      entry[database_index_name] = {"db_path" => database_path+"_"+timestamp_str, "db_name" => database_name+"_"+timestamp_str}
    end
    @fcmpa_db_indexer_db.save_everything_to_files!
  end

  def db(database_index_name)
    return @fcmpa_active_databases[database_index_name]
  end
  

  def start_database(database_index_name)
    @fcmpa_active_databases[database_index_name].load_everything_from_files!
  end

  def start_databases
    @fcmpa_db_indexer_db.each do |entry|
      entry.each do |key, value|
        temp = ManagedPartitionedArray.new(endless_add: true,
    dynamically_allocates: true,
      has_capacity: false,
        partition_amount_and_offset: PARTITION_AMOUNT + OFFSET,
          db_size: DB_SIZE,
            db_name: value["db_name"],
              db_path: value["db_path"])
        temp.load_everything_from_files!
        @fcmpa_active_databases[key] = temp
      end
    end
  end

  def stop_databases!
    @fcmpa_active_databases.each do |key, value|
      value.delete
    end
  end

  def stop_database!(database_index_name)
    @fcmpa_active_databases[database_index_name].delete
  end

  def save_database!(database_index_name)
    @fcmpa_active_databases[database_index_name].save_everything_to_files!
  end

  def save_databases!
    @fcmpa_active_databases.each do |key, value|
      value.save_everything_to_files!
    end
  end



end


#
#
test = FileContextManagedPartitionedArray.new
test.new_database(database_index_name_str: "test", db_path: "./DB", db_name: "test")
test.new_database(database_index_name_str: "test2", db_path: "./DB", db_name: "test2")
test.db("test").set(0) do |entry|
  entry["test"] = "test"
end
test.db("test").save_everything_to_files!

puts test.db("test").get(0, hash: true)