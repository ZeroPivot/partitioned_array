require_relative 'managed_partitioned_array'

# VERSION v1.0.3 - the basics are working
# VERSION v1.0.2 - left off working on start_database! -- turns out that
# this class requires more work before the partitioned array manager will.
# VERSION v1.0.1 
# VERSION v1.0.0a - release test run
# VERSION v0.2.3
# VERSION v0.2.2a (11/27/2022 - 10:20am)
# VERSION v0.2.1a (11/27/2022 - 6:25am)
# VERSION v0.2.0a 
# Refining before field testing
class FileContextManagedPartitionedArray
  attr_accessor :data_arr, :fcmpa_db_indexer_db, :fcmpa_active_databases, :active_database, :db_file_incrementor, :db_file_location, :db_path, :db_name, :db_size, :db_endless_add, :db_has_capacity, :fcmpa_db_indexer_name, :fcmpa_db_folder_name, :fcmpa_db_size, :fcmpa_partition_amount_and_offset, :db_partition_amount_and_offset, :partition_addition_amount, :db_dynamically_allocates, :timestamp_str
 
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
  DB_PATH = "./DB/FCMPA_DB"
  DB_HAS_CAPACITY = true
  DB_DYNAMICALLY_ALLOCATES = true
  DB_ENDLESS_ADD = true
  FCMPA_DB_INDEX_LOCATION = 0
  TRAVERSE_HASH = true
  FCMPA_ENDLESS_ADD = true
  FCMPA_DB_DYNAMICALLY_ALLOCATES = true
  FCMPA_PARTITION_ADDITION_AMOUNT = 5
  FCMPA_DB_HAS_CAPACITY = true
  DB_PARTITION_AMOUNT = 9
  DB_PARTITION_OFFSET = 1
  DB_PARTITION_ADDITION_AMOUNT = 5
  DEBUG = true

  def debug(say)
    puts say if DEBUG
  end

  def initialize(fcmpa_db_has_capacity: FCMPA_DB_HAS_CAPACITY, 
                 fcmpa_partition_addition_amount: FCMPA_PARTITION_ADDITION_AMOUNT,
                 fcmpa_db_dynamically_allocates: FCMPA_DB_DYNAMICALLY_ALLOCATES,
                 fcmpa_endless_add: FCMPA_ENDLESS_ADD,
                 traverse_hash: TRAVERSE_HASH,
                 partition_addition_amount: PARTITION_ADDITION_AMOUNT,
                 db_size: DB_SIZE,
                 db_endless_add: DB_ENDLESS_ADD,
                 db_has_capacity: DB_HAS_CAPACITY,
                 db_name: DB_NAME,
                 db_path: DB_PATH,
                 db_partition_addition_amount: DB_PARTITION_ADDITION_AMOUNT,
                 fcmpa_db_indexer_name: FCMPA_DB_INDEXER_NAME,
                 fcmpa_db_folder_name: FCMPA_DB_FOLDER_NAME,
                 fcmpa_db_size: FCMPA_DB_SIZE,
                 fcmpa_partition_amount_and_offset: FCMPA_PARTITION_AMOUNT + FCMPA_OFFSET,
                 db_partition_amount_and_offset: DB_PARTITION_AMOUNT + DB_PARTITION_OFFSET,
                 db_dynamically_allocates: DB_DYNAMICALLY_ALLOCATES,
                 fcmpa_db_index_location: FCMPA_DB_INDEX_LOCATION)

    @fcmpa_partition_amount_and_offset = fcmpa_partition_amount_and_offset
    @db_partition_amount_and_offset =  db_partition_amount_and_offset
    @fcmpa_db_size = fcmpa_db_size
    @partition_addition_amount = partition_addition_amount
    @fcmpa_db_indexer_name = fcmpa_db_indexer_name
    @fcmpa_db_folder_name = fcmpa_db_folder_name
    @fcmpa_endless_add = fcmpa_endless_add
    @db_has_capacity = db_has_capacity
    @db_endless_add = db_endless_add
    @db_partition_addition_amount = db_partition_addition_amount
    @fcmpa_db_has_capacity = fcmpa_db_has_capacity
    @db_size = db_size
    @db_path = db_path
    @db_name = db_name
    @fcmpa_partition_addition_amount = fcmpa_partition_addition_amount
    @traverse_hash = traverse_hash
    @db_dynamically_allocates = db_dynamically_allocates
    @fcmpa_db_dynamically_allocates = fcmpa_db_dynamically_allocates
    @fcmpa_db_index_location = fcmpa_db_index_location
    

    #@fcmpa_db_indexer_db.allocate
    

    @db_file_location = 0
    @db_file_incrementor = 0    
    @fcmpa_active_databases = {}
    @fcmpa_db_indexer = ""
    @timestamp_str = Time.now.strftime("%Y-%m-%d-%H-%M-%S")
    load_indexer_db!
  end

  def load_indexer_db!
    @fcmpa_db_indexer_db = ManagedPartitionedArray.new(endless_add: @fcmpa_endless_add,
                                                       dynamically_allocates: @fcmpa_db_dynamically_allocates,
                                                       has_capacity: @fcmpa_db_has_capacity,
                                                       partition_addition_amount: @fcmpa_partition_addition_amount,
                                                       partition_amount_and_offset: @fcmpa_partition_amount_and_offset,
                                                       db_size: @fcmpa_db_size,
                                                       db_name: @fcmpa_db_indexer_name,
                                                       db_path: @fcmpa_db_folder_name)
    
    #puts @fcmpa_db_indexer_db
    @fcmpa_db_indexer_db.allocate
    
    begin
      @fcmpa_db_indexer_db.load_everything_from_files!
    rescue
      @fcmpa_db_indexer_db.save_everything_to_files!
    end
  end

  def new_database(database_index_name_str, fcmpa_db_index_location: @fcmpa_db_index_location)
    timestamp_str = @timestamp_str # the string to give uniqueness to each database file context
    db_name_str = database_index_name_str
    puts @fcmpa_db_indexer_db.get(fcmpa_db_index_location)
  
    return true if !@fcmpa_db_indexer_db.get(fcmpa_db_index_location)["db_name"].nil? #guard clause to prevent overwriting the database index file
  debug "THIS: #{@fcmpa_db_indexer_db.get(fcmpa_db_index_location)["db_name"]}"
    gets
     
      @fcmpa_db_indexer_db.set(fcmpa_db_index_location) do |entry|
        entry[db_name_str] = {"db_path" => @db_path+"_"+timestamp_str, "db_name" => @db_name+"_"+timestamp_str}
      end
      @fcmpa_db_indexer_db.save_everything_to_files!
    #@db_file_incrementor += 1   
    


#fcmpa db indexer variable takes the responsibility of maintaining these databases via key names
      temp = ManagedPartitionedArray.new(endless_add: @db_endless_add,
                                        dynamically_allocates: @db_dynamically_allocates,
                                        has_capacity: @db_has_capacity,
                                        partition_addition_amount: @db_partition_addition_amount,
                                        partition_amount_and_offset: @db_partition_amount_and_offset,
                                        db_size: @db_size,
                                        db_name: @db_name+"_"+timestamp_str,
                                        db_path: @db_path+"_"+timestamp_str)
  


      temp.allocate
      @fcmpa_active_databases[db_name_str] = temp
      temp.save_everything_to_files!
      return temp

  
  
  end
  
  def delete_database_from_index!(database_index_name, fcmpa_db_index_location: @fcmpa_db_index_location)
    @fcmpa_db_indexer_db.set(fcmpa_db_index_location) do |entry|
      entry.delete(database_index_name)
    end
    @fcmpa_db_indexer_db.save_everything_to_files!
    @fcmpa_active_databases.delete(database_index_name)
  end
    
  def add_database_to_index(database_index_name, database_path, database_name, fcmpa_db_index_location: @fcmpa_db_index_location)
    #timestamp_str = @timestamp_str # the string to give uniqueness to each database file context
    @fcmpa_db_indexer_db.set(fcmpa_db_index_location) do |entry|
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
    @fcmpa_db_indexer_db.set(@fcmpa_db_index_location) do |entry|
      entry.delete(database_index_name)
      debug "deleted database #{database_index_name} from index"
    end
    @fcmpa_db_indexer_db.save_everything_to_files!
    @fcmpa_active_databases.delete(database_index_name)
  end

  # left off making it so that the database auto allocates and auto loads and saves on call
  def start_database!(database_index_name)
    db_index = @fcmpa_db_indexer_db.get(@fcmpa_db_index_location)
    if db_index[database_index_name].nil?
      new_database(database_index_name)
    else
      debug "db index debug #{db_index}"    
      db_name = db_index[database_index_name]["db_name"]
      db_path = db_index[database_index_name]["db_path"]
      debug "db name debug #{db_name}"
      debug "db path debug #{db_path}"
      debug "db index debug #{db_index.keys}"
      gets
      @fcmpa_active_databases[database_index_name] = ManagedPartitionedArray.new(endless_add: @db_endless_add,
                                                                                dynamically_allocates: @db_dynamically_allocates,
                                                                                has_capacity: @db_has_capacity,
                                                                                partition_addition_amount: @db_partition_addition_amount,
                                                                                partition_amount_and_offset: @db_partition_amount_and_offset,
                                                                                db_size: @db_size,
                                                                                db_name: db_name,
                                                                                db_path: db_path)
      @fcmpa_active_databases[database_index_name].allocate
    begin
      @fcmpa_active_databases[database_index_name].load_everything_from_files!
    rescue
      @fcmpa_db_indexer_db.save_everything_to_files!    
    end
   #if the database index is nil, then the database has not been created yet
    
  end



#fcmpa db indexer variable takes the responsibility of maintaining these databases via key names
    #@fcmpa_active_databases[database_index_name] = @fcmpa_active_databases[database_index_name].load_everything_from_files!
    
    #puts "returning..."
    
    return @fcmpa_active_databases[database_index_name]
  end


  

  def stop_databases!
    @fcmpa_active_databases.each do |key, value|
      @fcmpa_active_databases.delete(key)
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
                                             partition_amount_and_offset: @db_partition_amount_and_offset,
                                             db_size: @db_size,
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
    @fcmpa_active_databases.each do |key, _|
      @fcmpa_active_databases[key].save_everything_to_files!
    end
  end

  def load_database!(database_index_name)  
    start_database!(database_index_name)
  end

  def load_databases!
    @fcmpa_active_databases.each do |key, _|
      start_database!(@fcmpa_active_databases[key])
    end

  end

  def delete_database!(database_index_name)
    @fcmpa_active_databases.delete(database_index_name)
    delete_database_from_index!(database_index_name)
    #@fcmpa_active_databases.save_everything_to_files!
  end
 
  def get_databases_list
     @fcmpa_active_databases.keys
  end

  def set_new_file_archive(database_index_name)
    temp = @fcmpa_active_databases[database_index_name]
    temp = temp.archive_and_new_db!
    @fcmpa_active_databases[database_index_name] = temp
  
    #temp = db(database_index_name)

  end

  def each(database_index_name, hash: @traverse_hash)
    return false if @fcmpa_active_databases[database_index_name].nil?
    database = @fcmpa_active_databases[database_index_name]
    database_size = database.data_arr.size - 1
    traverse_hash = hash
    #exit
    0.upto(database_size) do |i|
      yield database.get(i, hash: traverse_hash)
    end
  end

  def each_not_nil(database_index_name, hash: traverse_hash)
    database = @fcmpa_active_databases[database_index_name]
    database_size = database.data_arr.size - 1
    #exit
    0.upto(database_size) do |i|
      t = database.get(i, hash: traverse_hash) # memory overhead reduction; make a temp since yield checks twice
      yield t if !t.nil?
    end
  end

end


#
#
#test = FileContextManagedPartitionedArray.new
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

test = FileContextManagedPartitionedArray.new()
test.new_database("test") # also renews the database; use with caution
#test.new_database("test2")
test.save_database!("test")
#test.save_database!("test2")
test.stop_database!("test")
test.stop_database!("test")
test.new_database("test2")
test.start_database!("test2")

a=test.db("test2").set(1) do |entry|
  entry["added data"] = "hello dragonruby"
  entry["test2"] = "test2"
end

puts a.to_s

test.stop_database!("test2")
test.db("test2").save_everything_to_files!
test.start_database!("test3")
test.db("test3").save_everything_to_files!
#test.delete_database!("test")
#test.delete_database_from_index!("test2")
#p y.get(0, hash: true)