require_relative 'file_context_managed_partitioned_array'

# VERSION v0.0.6
# VERSION v0.0.5

class FileContextManagedPartitionedArrayManager
  
  attr_accessor :data_arr, :fcmpa_db_indexer_db, :fcmpa_active_databases, :active_database, :db_file_incrementor, :db_file_location, :db_path, :db_name, :db_size, :db_endless_add, :db_has_capacity, :fcmpa_db_indexer_name, :fcmpa_db_folder_name, :fcmpa_db_size, :fcmpa_partition_amount_and_offset, :db_partition_amount_and_offset, :partition_addition_amount, :db_dynamically_allocates, :timestamp_str
 
  # DB_SIZE > PARTITION_AMOUNT
  TRAVERSE_HASH = true
  FCMPA_PARTITION_AMOUNT = 9
  FCMPA_OFFSET = 1
  FCMPA_DB_ENDLESS_ADD = true
  FCMPA_DB_DYNAMICALLY_ALLOCATES = true
  FCMPA_DB_PARTITION_ADDITION_AMOUNT = 5
  FCMPA_DB_HAS_CAPACITY = true
  FCMPA_DB_MAX_CAPACITY = "data_arr_size"
  FCMPA_DB_INDEXER_NAME = "FCMPA_DB_INDEX"
  FCMPA_DB_FOLDER_NAME = "./DB/FCMPAM_INDEX_DB"
  FCMPA_DB_PARTITION_ARCHIVE_ID = 0
  FCMPA_DB_SIZE = 20
  FCMPA_DB_INDEX_LOCATION = 0


  # FCMPA_DB_[type]
  DB_PARTITION_AMOUNT = 9
  DB_PARTITION_OFFSET = 1
  DB_NAME = "FCMPA_DB"
  DB_PATH = "./DB/FCMPAM_DB"
  DB_HAS_CAPACITY = true
  DB_DYNAMICALLY_ALLOCATES = true
  DB_ENDLESS_ADD = true
  DB_MAX_CAPACITY = "data_arr_size"
  DB_PARTITION_ARCHIVE_ID = 0
  DB_SIZE = 20
  DB_PARTITION_ADDITION_AMOUNT = 5


  MAN_DB_PARTITION_AMOUNT = 9
  MAN_DB_OFFSET = 1
  MAN_DB_SIZE = 20
  MAN_DB_DYNAMICALLY_ALLOCATES = true
  MAN_DB_ENDLESS_ADD = true
  MAN_DB_INDEX_LOCATION = 0
  MAN_DB_PARTITION_ADDITION_AMOUNT = 5
  MAN_DB_HAS_CAPACITY = true
  MAN_DB_MAX_CAPACITY = "data_arr_size"
  MAN_DB_FOLDER_NAME = "MAN_INDEX_DB" 
  MAN_DB_INDEXER_NAME = "./DB/MAN_INDEX_DB"
  MAN_DB_PARTITION_ARCHIVE_ID = 0

  # db
  # fcmpa
  # man_db

  def initialize(
                 db_max_capacity: DB_MAX_CAPACITY,
                 db_size: DB_SIZE,
                 db_endless_add: DB_ENDLESS_ADD,
                 db_has_capacity: DB_HAS_CAPACITY,
                 db_name: DB_NAME,
                 db_path: DB_PATH,
                 db_partition_addition_amount: DB_PARTITION_ADDITION_AMOUNT,
                 db_dynamically_allocates: DB_DYNAMICALLY_ALLOCATES,   
                 db_partition_amount_and_offset: DB_PARTITION_AMOUNT + DB_PARTITION_OFFSET,
                 db_partition_archive_id: DB_PARTITION_ARCHIVE_ID,
                 fcmpa_db_size: FCMPA_DB_SIZE,
                 fcmpa_db_indexer_name: FCMPA_DB_INDEXER_NAME,                
                 fcmpa_db_index_location: FCMPA_DB_INDEX_LOCATION,       
                 fcmpa_db_folder_name: FCMPA_DB_FOLDER_NAME,
                 fcmpa_db_partition_amount_and_offset: FCMPA_PARTITION_AMOUNT + FCMPA_OFFSET,
                 fcmpa_db_has_capacity: FCMPA_DB_HAS_CAPACITY, 
                 fcmpa_db_partition_addition_amount: FCMPA_DB_PARTITION_ADDITION_AMOUNT,
                 fcmpa_db_dynamically_allocates: FCMPA_DB_DYNAMICALLY_ALLOCATES,
                 fcmpa_db_endless_add: FCMPA_DB_ENDLESS_ADD,
                 fcmpa_db_max_capacity: FCMPA_DB_MAX_CAPACITY, 
                 fcmpa_db_partition_archive_id: FCMPA_DB_PARTITION_ARCHIVE_ID,         
                 man_db_offset: MAN_DB_OFFSET,
                 man_db_size: MAN_DB_SIZE,          
                 man_db_folder_name: MAN_DB_FOLDER_NAME,
                 man_db_has_capacity: MAN_DB_HAS_CAPACITY,
                 man_db_dynamically_allocates: MAN_DB_DYNAMICALLY_ALLOCATES,
                 man_db_endless_add: MAN_DB_ENDLESS_ADD,
                 man_db_partition_addition_amount: MAN_DB_PARTITION_ADDITION_AMOUNT,
                 man_db_partition_amount_and_offset: MAN_DB_PARTITION_AMOUNT + MAN_DB_OFFSET,                 
                 man_db_indexer_name: MAN_DB_INDEXER_NAME,
                 man_db_partition_archive_id: MAN_DB_PARTITION_ARCHIVE_ID,
                 man_db_max_capacity: MAN_DB_MAX_CAPACITY
                 )
          
    @fcmpa_db_partition_archive_id = fcmpa_db_partition_archive_id
    @fcmpa_db_endless_add = fcmpa_db_endless_add
    @fcmpa_db_partition_amount_and_offset = fcmpa_db_partition_amount_and_offset
    @fcmpa_db_max_capacity = fcmpa_db_max_capacity
    @fcmpa_db_index_location = fcmpa_db_index_location
    @fcmpa_db_size = fcmpa_db_size
    @fcmpa_db_indexer_name = fcmpa_db_indexer_name
    @fcmpa_db_folder_name = fcmpa_db_folder_name
    @fcmpa_db_partition_addition_amount = fcmpa_db_partition_addition_amount
    @fcmpa_db_has_capacity = fcmpa_db_has_capacity
    @fcmpa_db_dynamically_allocates = fcmpa_db_dynamically_allocates
    @fcmpa_db_partition_addition_amount = fcmpa_db_partition_addition_amount

    
    # The database which holds all the entries that the manager database manages
    @db_has_capacity = db_has_capacity
    @db_endless_add = db_endless_add    
    @db_size = db_size
    @db_path = db_path
    @db_name = db_name
    @db_dynamically_allocates = db_dynamically_allocates
    @db_partition_amount_and_offset =  db_partition_amount_and_offset
    @db_max_capacity = db_max_capacity
    @db_partition_addition_amount = db_partition_addition_amount
    @db_partition_archive_id = db_partition_archive_id
    # manager database /aritywolf/gallery,etc #=> in this case, aritywolf is the manager of gallery,etc
    @man_db_offset = man_db_offset
    @man_db_size = man_db_size
    @man_db_folder_name = man_db_folder_name
    @man_db_has_capacity = man_db_has_capacity
    @man_db_dynamically_allocates = man_db_dynamically_allocates
    @man_db_endless_add = man_db_endless_add
    @man_db_partition_addition_amount = man_db_partition_addition_amount
    @man_db_partition_amount_and_offset = man_db_partition_amount_and_offset
    #@man_db_indexer_name = man_db_indexer_name
    @man_db_indexer_name= man_db_indexer_name
    @man_db_partition_archive_id = man_db_partition_archive_id
    @man_db_max_capacity = man_db_max_capacity
    @timestamp_str = Time.now.strftime("%Y-%m-%d-%H-%M-%S")

    @man_index = FileContextManagedPartitionedArray.new(fcmpa_db_partition_amount_and_offset: @fcmpa_db_partition_amount_and_offset,
                                                        fcmpa_db_size: @fcmpa_db_size,
                                                        fcmpa_db_indexer_name: @fcmpa_db_indexer_name+"_"+"indexer",
                                                        fcmpa_db_folder_name: @fcmpa_db_folder_name,
                                                        fcmpa_db_dynamically_allocates: @fcmpa_db_dynamically_allocates,
                                                        fcmpa_db_endless_add: @fcmpa_endless_add,
                                                        fcmpa_db_partition_addition_amount: @man_db_partition_addition_amount,
                                                        fcmpa_db_has_capacity: @fcmpa_db_has_capacity,
                                                        fcmpa_db_index_location: @fcmpa_db_index_location,                                                    
                                                        fcmpa_db_max_capacity: @fcmpa_db_max_capacity, 
                                                        fcmpa_db_partition_archive_id: @fcmpa_db_partition_archive_id, 
                                                        db_partition_addition_amount: @partition_addition_amount,
                                                        db_size: @db_size,
                                                        db_endless_add: @db_endless_add,
                                                        db_has_capacity: @db_has_capacity,
                                                        db_name: @db_name, #difference: man_indexer instead of man_db_
                                                        db_path: @db_path, #                                                       
                                                        db_dynamically_allocates: @db_dynamically_allocates,
                                                        db_partition_amount_and_offset: @db_partition_amount_and_offset,
                                                        db_max_capacity: @db_max_capacity,
                                                        db_partition_archive_id: @db_partition_archive_id,
                                                        traverse_hash: @traverse_hash
                                                        )
# a man_db entry for every single database table, while man_index maintains the link between the manager database and the database tables
    @man_db = FileContextManagedPartitionedArray.new(fcmpa_db_partition_amount_and_offset: @fcmpa_db_partition_amount_and_offset,
                                                        fcmpa_db_size: @fcmpa_db_size,
                                                        fcmpa_db_indexer_name: @fcmpa_db_indexer_name+"_"+"database",
                                                        fcmpa_db_folder_name: @fcmpa_db_folder_name,
                                                        fcmpa_db_dynamically_allocates: @fcmpa_db_dynamically_allocates,
                                                        fcmpa_db_endless_add: @fcmpa_endless_add,
                                                        fcmpa_db_partition_addition_amount: @man_db_partition_addition_amount,
                                                        fcmpa_db_has_capacity: @fcmpa_db_has_capacity,
                                                        fcmpa_db_index_location: @fcmpa_db_index_location,                                                    
                                                        fcmpa_db_max_capacity: @fcmpa_db_max_capacity, 
                                                        fcmpa_db_partition_archive_id: @fcmpa_db_partition_archive_id, 
                                                        db_partition_addition_amount: @partition_addition_amount,
                                                        db_size: @db_size, #
                                                        db_endless_add: @db_endless_add, #
                                                        db_has_capacity: @db_has_capacity, #
                                                        db_name: @db_name, #difference: man_indexer instead of man_db_
                                                        db_path: @db_path, #      #                                                 
                                                        db_dynamically_allocates: @db_dynamically_allocates, #
                                                        db_partition_amount_and_offset: @db_partition_amount_and_offset, #
                                                        db_max_capacity: @db_max_capacity, #
                                                        db_partition_archive_id: @db_partition_archive_id, #

                                                        traverse_hash: @traverse_hash)


  end

  # define @man_index as the database index for @man_db
  def start_man!


    
  end


  def start_man(database_name = "database_name")
   # if the table entry contains the table name in @man_index, then initialize the table and thus the database
    if !@man_index[database_name] # if the table entry does not exist in @man_index, then initialize the table and thus the database
      # initialize database
      #@man_index[database_name]
      @man_index.start_database(database_name)
      @man_index.set(0) do |hash|
        hash[database_name]["db_name"] = database_name
        hash[database_name]["db_path"] = @db_path+database_name
      end
      @man_index.save_everything_to_files!
    end
  end

# the index is the database name, and man__db maintains the databases defined by the index
  def new_databases_test(database_name, database_table)

    @man_index.start_database!(database_name)
    @man_db.start_database!(database_table)

  #  puts @man_index.db("database_tables_index")
    @man_index.db(database_name).set(0) do |hash|
      hash[database_name]["db_name"] = database_name
      hash[database_name]["db_path"] = @db_path+"_"+database_name
      hash[database_name]["db_table_name"] = database_table
      
    end      

  
    puts @man_index.db(database_name)
    gets

    @man_index.db(database_name).save_everything_to_files!
    @man_db.db(database_table).save_everything_to_files!
  #  @man_index.allocate
  #  @man_db.allocate
  #  @man_index.save_everything_to_files!
    #@man_db.save_everything_to_files!
  end

  def man(database_name = "test_database_run")
    puts @man_db
   database = @man_db
    puts @man_index
  puts @man_index.db("test_database_run").get(0)

  end

  




end

a = FileContextManagedPartitionedArrayManager.new
a.new_databases_test("test_database_run", "test_database_table_run")
a.man