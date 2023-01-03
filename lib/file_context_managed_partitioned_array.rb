# rubocop:disable Style/StringLiterals
# rubocop:disable Style/MutableConstant
# rubocop:disable Metrics/ClassLength
require_relative 'managed_partitioned_array'

# VERSION v0.2.8 - reduced redundancy that happened by accident
# VERSION v0.2.7a - organized variables, fixed database overwrite bug, which was just giving each database "table" in the file heiratchy the name of itself
# VERSION v0.2.6 - organized variables, some debugging to make sure everything is set correctly initially - 11:31AM
# VERSION v0.2.5 - 2022-12-05 10:10AM
# FileContextManagedPartitionedArray
#  A ManagedPartitionedArray that uses a FileContext to store its data.
# Fixed variable definitions and usage locations; program works as it did in an earlier version without the variable misuse and collisions.
# VERSION v0.2.4
# VERSION v0.2.3 - the basics are working
# VERSION v0.2.2 - left off working on start_database! -- turns out that
# this class requires more work before the partitioned array manager will.
# VERSION v0.2.1
# VERSION v0.2.0a - release test run
# VERSION v0.2.3
# VERSION v0.2.2a (11/27/2022 - 10:20am)
# VERSION v0.2.1a (11/27/2022 - 6:25am)
# VERSION v0.2.0a
# Refining before field testing
class FileContextManagedPartitionedArray
  attr_accessor :fcmpa_db_indexer_db, :fcmpa_active_databases, :active_database, :db_file_incrementor, :db_file_location, :db_path, :db_name, :db_size, :db_endless_add, :db_has_capacity, :fcmpa_db_indexer_name, :fcmpa_db_folder_name, :fcmpa_db_size, :fcmpa_partition_amount_and_offset, :db_partition_amount_and_offset, :partition_addition_amount, :db_dynamically_allocates, :timestamp_str
 
  # DB_SIZE > PARTITION_AMOUNT  
  DB_SIZE = 20 # Caveat: The DB_SIZE is the total # of partitions, but you subtract it by one since the first partition is 0, in code. that is, it is from 0 to DB_SIZE-1, but DB_SIZE is then the max allocated DB size
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
  
  TRAVERSE_HASH = true
  DEBUG = true

  RAISE_ON_NO_DB = false

  def debug(say)
    puts say if DEBUG
  end

  def initialize(raise_on_no_db: RAISE_ON_NO_DB,
                 traverse_hash: TRAVERSE_HASH,
                 db_max_capacity: DB_MAX_CAPACITY,
                 db_size: DB_SIZE,
                 db_endless_add: DB_ENDLESS_ADD,
                 db_has_capacity: DB_HAS_CAPACITY,
                 db_name: DB_NAME,
                 db_path: DB_PATH,
                 db_partition_amount_and_offset: DB_PARTITION_AMOUNT + DB_PARTITION_OFFSET,
                 db_dynamically_allocates: DB_DYNAMICALLY_ALLOCATES,
                 db_partition_addition_amount: DB_PARTITION_ADDITION_AMOUNT,
                 db_partition_archive_id: DB_PARTITION_ARCHIVE_ID,
                 fcmpa_db_indexer_name: FCMPA_DB_INDEXER_NAME,
                 fcmpa_db_folder_name: FCMPA_DB_FOLDER_NAME,
                 fcmpa_db_size: FCMPA_DB_SIZE,
                 fcmpa_db_partition_amount_and_offset: FCMPA_DB_PARTITION_AMOUNT + FCMPA_DB_OFFSET,
                 fcmpa_db_has_capacity: FCMPA_DB_HAS_CAPACITY, 
                 fcmpa_db_partition_addition_amount: FCMPA_DB_PARTITION_ADDITION_AMOUNT,
                 fcmpa_db_dynamically_allocates: FCMPA_DB_DYNAMICALLY_ALLOCATES,
                 fcmpa_db_endless_add: FCMPA_DB_ENDLESS_ADD,
                 fcmpa_db_max_capacity: FCMPA_DB_MAX_CAPACITY,
                 fcmpa_db_partition_archive_id: FCMPA_DB_PARTITION_ARCHIVE_ID,
                 fcmpa_db_index_location: FCMPA_DB_INDEX_LOCATION
                 )


    @traverse_hash = traverse_hash


    @raise_on_no_db = raise_on_no_db

    @db_max_capacity = db_max_capacity 
    @db_partition_amount_and_offset =  db_partition_amount_and_offset #
    @db_dynamically_allocates = db_dynamically_allocates # 
    @db_has_capacity = db_has_capacity #
    @db_endless_add = db_endless_add #
    @db_partition_addition_amount = db_partition_addition_amount #
    @db_size = db_size #
    @db_path = db_path #
    @db_name = db_name #
    @db_partition_archive_id = db_partition_archive_id #


    @fcmpa_db_dynamically_allocates = fcmpa_db_dynamically_allocates
    @fcmpa_db_indexer_name = fcmpa_db_indexer_name
    @fcmpa_db_folder_name = fcmpa_db_folder_name
    @fcmpa_db_size = fcmpa_db_size
    @fcmpa_db_endless_add = fcmpa_db_endless_add
    @fcmpa_db_has_capacity = fcmpa_db_has_capacity
    @fcmpa_db_partition_addition_amount = fcmpa_db_partition_addition_amount
    @fcmpa_db_max_capacity = fcmpa_db_max_capacity
    @fcmpa_db_partition_amount_and_offset = fcmpa_db_partition_amount_and_offset
    @fcmpa_db_partition_archive_id = fcmpa_db_partition_archive_id
    @fcmpa_db_index_location = fcmpa_db_index_location
    @fcmpa_active_databases = {}
    @fcmpa_db_indexer_db = {}
    @timestamp_str = new_timestamp
    load_indexer_db!
    #puts "FCMPA_DB_INDEXER: #{@fcmpa_db_indexer_db}" 
    #exit
  end

  def load_indexer_db!
    @fcmpa_db_indexer_db = ManagedPartitionedArray.new(endless_add: @fcmpa_db_endless_add,
                                                       dynamically_allocates: @fcmpa_db_dynamically_allocates,
                                                       has_capacity: @fcmpa_db_has_capacity,
                                                       partition_addition_amount: @fcmpa_db_partition_addition_amount,
                                                       partition_amount_and_offset: @fcmpa_db_partition_amount_and_offset,
                                                       db_size: @fcmpa_db_size,
                                                       db_name: @fcmpa_db_indexer_name,
                                                       db_path: @fcmpa_db_folder_name,
                                                       max_capacity: @fcmpa_max_capacity,
                                                       partition_archive_id: @fcmpa_db_partition_archive_id
                                                       )
    
   
    @fcmpa_db_indexer_db.allocate
    
    begin
      @fcmpa_db_indexer_db.load_everything_from_files!
    rescue
      @fcmpa_db_indexer_db.save_everything_to_files!
    end
  end

  def new_timestamp
    Time.now.to_i.to_s
  end

  def new_database(database_index_name_str, fcmpa_db_index_location: @fcmpa_db_index_location, db_name: @db_name, db_path: @db_path, only_path: false, only_name: false)
    timestamp_str = new_timestamp # the string to give uniqueness to each database file context
    db_name_str = database_index_name_str
    #puts @fcmpa_db_indexer_db.get(fcmpa_db_index_location)
   #puts @fcmpa_db_indexer_db.get(fcmpa_db_index_location)
   #gets
   #puts "db_name_str: #{db_name_str}"
    return true if !@fcmpa_db_indexer_db.get(fcmpa_db_index_location)["db_name"].nil? #guard clause to prevent overwriting the database index file
    #puts !@fcmpa_db_indexer_db.get(fcmpa_db_index_location)["db_name"].nil?
    #gets
    #puts "allocating new database (guard clause failed)"
    #path = ""
    #if only_path
    #  path = db_path
    #else
      path = db_path+"_"+db_name_str
    #end

    @fcmpa_db_indexer_db.set(fcmpa_db_index_location) do |entry|
      #entry[db_name_str] = {"db_path" => @db_path+"_"+db_name_str, "db_name" => @db_name+"_"+db_name_str} if !only_path
      entry[db_name_str] = {"db_path" => path, "db_name" => db_name+"_"+db_name_str, "db_table_name" => [] }# if only_path

    end
    @fcmpa_db_indexer_db.save_everything_to_files!
  #db indexer variable takes the responsibility of maintaining these databases via key names
    temp = ManagedPartitionedArray.new(endless_add: @db_endless_add,
                                      dynamically_allocates: @db_dynamically_allocates,
                                      has_capacity: @db_has_capacity,
                                      max_capacity: @db_max_capacity,
                                      partition_addition_amount: @db_partition_addition_amount,
                                      partition_amount_and_offset: @db_partition_amount_and_offset,
                                      db_size: @db_size,
                                      db_name: db_name+"_"+db_name_str,
                                      db_path: path,
                                      partition_archive_id: @db_partition_archive_id)
    temp.allocate
    #puts "db_path: #{temp.db_path}"
    @fcmpa_active_databases[db_name_str] = temp
    #temp.save_everything_to_files!
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
      entry[database_index_name] = {"db_path" => database_path, "db_name" => database_name}
    end
    @fcmpa_db_indexer_db.save_everything_to_files!
  end

  def db(database_index_name = @active_database)
    #puts @fcmpa_active_databases.to_s
    
    @fcmpa_active_databases[database_index_name]
  end
  
  def set_active_database(database_index_name)
    @active_database = database_index_name
  end


  def stop_database!(database_index_name)
    @fcmpa_db_indexer_db.set(@fcmpa_db_index_location) do |entry|
      entry.delete(database_index_name)
      #debug "deleted database #{database_index_name} from index"
    end
    @fcmpa_db_indexer_db.save_everything_to_files!
    @fcmpa_active_databases.delete(database_index_name)
  end

  # left off making it so that the database auto allocates and auto loads and saves on call
  def start_database!(database_index_name, raise_on_no_db: false, db_name: @db_name, db_path: @db_path, only_path: false, only_name: false)
    db_index = @fcmpa_db_indexer_db.get(@fcmpa_db_index_location)
    if db_index[database_index_name].nil?
      raise if raise_on_no_db 
      #puts "new database"
      #puts "database_index_name: #{database_index_name}"
      #puts "db_index[datatabase_table_name] #{db_index[database_index_name]} exists"
      new_database(database_index_name, db_name: db_name, db_path: db_path) #start a new database if one wasn't assigned
      #puts "db_name: #{db_name}"
      #puts "db_path: #{db_path}"
    else
      #debug "db index debug #{db_index}" 
      #puts "db_index[database_index_name] doesn't exist"   
      db_name = db_index[database_index_name]["db_name"]
      db_path = db_index[database_index_name]["db_path"]
      #debug "db name debug #{db_name}"
      #debug "db path debug #{db_path}"
      #debug "db index debug #{db_index.keys}"
      
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
                                                                                  partition_archive_id: @db_partition_archive_id
                                                                                )
      begin
        @fcmpa_active_databases[database_index_name].load_everything_from_files!
        puts "database loaded"
      rescue
        @fcmpa_active_databases[database_index_name].allocate
        @fcmpa_active_databases[database_index_name].save_everything_to_files!
        puts "new database saved"
      end

    
      
   #   puts "saved everything to files"

   #if the database index is nil, then the database has not been created yet
    #if the database index is not nil, then the database has been created and we can load it
    end

    return @fcmpa_active_databases[database_index_name]
  end


  
  # ! denotes that this is an action that will be performed on the database and not a query
  def stop_databases!
    @fcmpa_active_databases.each do |key, _|
      @fcmpa_active_databases.delete(key)
    end

  end

  def save_database!(database_index_name = @active_database)
    @fcmpa_active_databases[database_index_name].save_everything_to_files!
  end

  def save_databases!
    @fcmpa_active_databases.each do |key, _|
      @fcmpa_active_databases[key].save_everything_to_files!
    end
  end

  def load_database!(database_index_name = @active_database)  
    start_database!(database_index_name)
  end

  def load_databases!
    @fcmpa_active_databases.each do |key, _|
      start_database!(@fcmpa_active_databases[key])
    end

  end

  def delete_database!(database_index_name = @active_database)
    @fcmpa_active_databases.delete(database_index_name)
    delete_database_from_index!(database_index_name)
    #@fcmpa_active_databases.save_everything_to_files!
  end
 
  def get_databases_list
     @fcmpa_active_databases.keys
  end

  def set_new_file_archive!(database_index_name = @active_database)
    temp = @fcmpa_active_databases[database_index_name]
    temp = temp.archive_and_new_db!
    @fcmpa_active_databases[database_index_name] = temp
  
    #temp = db(database_index_name)

  end

  #traverses the database and yields every element in @data_arr, even nils
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


# traverses the database and returns all elements that are not nil, across all of @data_arr
  def each_not_nil(database_index_name, hash: @traverse_hash)
    database = @fcmpa_active_databases[database_index_name]
    database_size = database.data_arr.size - 1
    traverse_hash = hash
    #exit
    0.upto(database_size) do |i|
      t = database.get(i, hash: traverse_hash) # memory overhead reduction; make a temp since yield checks twice
      yield t if !t.nil?
    end
  end

end

=begin
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
#stest.new_database("test2")
test.start_database!("test2")
test.start_database!("test3")
a=test.db("test2").set(0) do |entry|
  entry["added data"] = "hello dragonruby"
  entry["test2"] = "test2"
end
a=test.db("test2").set(1) do |entry|
  entry["added data"] = "hello dragonruby"
  entry["test2"] = "test2"
end
test.db("test2").save_everything_to_files!


a=test.db("test3").set(1) do |entry|
  entry["added data"] = "hello dragonruby"
  entry["test2"] = "test2"
end
test.db("test3").save_everything_to_files!
test.db("test2").save_everything_to_files!
#test.delete_database!("test")
#test.delete_database_from_index!("test2")
#p y.get(0, hash: true)
=end # rubocop:enable Metrics/ClassLength
# rubocop:enable Style/MutableConstant
# rubocop:enable Style/StringLiterals
