require_relative 'file_context_managed_partitioned_array'

# VERSION v1.0.2a - working on new_database, where the database table entries have to contain an array of the tables, so the database knows which tables belong to it
# VERSION v1.0.1a - -left off at line 169
# VERSION v0.1.0a - BASICS are working, in new_database_test (12/6/2022 - 8:14am)
# VERSION v0.0.6
# VERSION v0.0.5

class FileContextManagedPartitionedArrayManager
  
  attr_accessor :fcmpa_db_indexer_db, :fcmpa_active_databases, :active_database, :db_file_incrementor, :db_file_location, :db_path, :db_name, :db_size, :db_endless_add, :db_has_capacity, :fcmpa_db_indexer_name, :fcmpa_db_folder_name, :fcmpa_db_size, :fcmpa_partition_amount_and_offset, :db_partition_amount_and_offset, :partition_addition_amount, :db_dynamically_allocates, :timestamp_str
 
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
  FCMPA_DB_FOLDER_NAME = "./DB/FCMPAM_DB_INDEX"
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
                 fcmpa_db_partition_archive_id: FCMPA_DB_PARTITION_ARCHIVE_ID                 
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
  
    @timestamp_str = Time.now.strftime("%Y-%m-%d-%H-%M-%S")

    @man_index = FileContextManagedPartitionedArray.new(fcmpa_db_partition_amount_and_offset: @fcmpa_db_partition_amount_and_offset,
                                                        fcmpa_db_size: @fcmpa_db_size,
                                                        fcmpa_db_indexer_name: @fcmpa_db_indexer_name+"_"+"indexer",
                                                        fcmpa_db_folder_name: @fcmpa_db_folder_name+"_"+"indexer",
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
                                                        fcmpa_db_folder_name: @fcmpa_db_folder_name+"_"+"database",
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
# update: left off worrying about the db_table_name entry having to contain an array of the table names so that the database knows which tables to look for and which ones belong to it
# left off working with new_table, and, setting the table apart from the database and placing them into independent folders (the problem is file locations)
  def new_table(database_table:, database_name:)
    # check to see if this table exists in the database first
  #  if @man_index.db(database_name).get(0)[database_name]["db_table_name"] == database_table
  # puts @man_index.db(database_name)
  #puts "table doesnt exist"
  
  #  

    #@man_db should contain the table entries for every database_table related to the database database_name in @man_db

    @man_db.start_database!(database_name, db_path: @db_path+"/MAN_DB_INDEX/INDEX", only_path: true, only_name: true, db_name: "INDEX")
    @man_index.start_database!(database_table, db_path: @db_path+"/MAN_DB_TABLE/#{database_name}/TABLE", only_path: true, only_name: true, db_name: "TABLE")
    
    begin 

    old_db_table_name = @man_index.db(database_table).get(0)
    puts "database_table: #{database_table}"
    puts "old table names (table exists): #{old_db_table_name}"
    gets
    @man_index.db(database_name).set(0) do |hash|
      hash[database_name] = { rand(9) => rand(9), "db_name" => database_name, "db_path" => @db_path+"/DB_#{database_name}", "db_table_name" => old_db_table_name << database_table}
   
    end
    puts "new table names (table doesn't exist): #{@man_index.db(database_name).get(0)[database_name]["db_table_name"]}"
    gets
    rescue
      puts "database doesn't have db_table_name entry"
      old_db_table_name = database_table
      @man_index.db(database_name).set(0) do |hash|
        hash[database_name] = { rand(9) => rand(9), "db_name" => database_name, "db_path" => @db_path+"/DB_#{database_name}", "db_table_name" => [old_db_table_name, "mark"]}
     
      end
    end
    
    puts "table and name in new_table beginning"

    puts "man_index: #{@man_index.db(database_table).get(0)[database_name]["db_table_name"]}"

    #puts "man 0: #{@man_index.db(database_table).get(0)}"
  
    @man_index.db(database_name).save_everything_to_files!
    @man_db.db(database_name).save_everything_to_files!
  end

# the index is the database name, and man__db maintains the databases defined by the index
  def new_database(database_name)
    @man_index.start_database!(database_name, db_path: @db_path+"/MAN_DB_INDEX/INDEX", only_path: true, only_name: false, db_name: "INDEX")

    #@man_index.db(database_name).set(0) do |hash|      

  end

  def man(database_name = "test_database_run")
    @man_index.db(database_name)
  end

  




end

a = FileContextManagedPartitionedArrayManager.new
#a.new_database("test_database_run")
#a.new_database("test_database")
a.new_database("test_database33")
#a.man("test_database").set(0) do |hash|
#  hash["test"] = "test"
#end

#a.new_table(database_name: "test_database33", database_table: "test_database_table23")
#a.new_table(database_name: "test_database33", database_table: "test_database_table24")
a.new_table(database_name: "test_database33", database_table: "test_database_table27")
#a.new_table(database_name: "test_database33", database_table: "test_database_table27")
#a.new_table(database_table: "test_database_table_run", database_name: "test_database_run2")
#p "a.man: #{a.man("test_database").get(0)}"
a.man("test_database33").save_everything_to_files!

#a.man("test_database3").save_everything_to_files!