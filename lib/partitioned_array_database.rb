require_relative 'file_context_managed_partitioned_array_manager'
# VERSION v0.0.3 - cleanup
# VERSION 0.0.2 - Database creation by superfolder
# VERSION 0.0.1 - Skeleton of the class created

class PartitionedArrayDatabase
  attr_accessor :database_folder_name, :pad
  FCMPAM_DB_INDEX_NAME = 'FCMPAM_DB_INDEX'
  DB_NAME = 'FCMPAM_DB'
  PARTITION_AMOUNT = 100
  ENDLESS_ADD = true
  HAS_CAPACITY = true
  DB_SIZE = 100
  DYNAMICALLY_ALLOCATES = true

  DATABASE_FOLDER_NAME = './default' # folder name in terms of a full or relative path  
  FCMPAM = FileContextManagedPartitionedArrayManager
  # For a change of database variables, check the file constants in the file_context_managed_partitioned_array_manager.rb library, etc.
  def initialize(database_file_name: DATABASE_FILE_NAME, endless_add: ENDLESS_ADD, has_capacity: DB_HAS_CAPACITY, dynamically_allocates: DYNAMICALLY_ALLOCATES, db_size: DATABASE_SIZE)
    @database_folder_name = database_file_name
    @endless_add = endless_add
    @has_capacity = has_capacity
    @db_size = db_size
    @dynamically_allocates = dynamically_allocates   
    @pad = FCMPAM.new(fcmpa_db_has_capacity: @has_capacity, db_dynamically_allocates: @dynamically_allocates, db_size: @db_size, db_path: "#{database_folder_name}/#{DB_NAME}", fcmpa_db_folder_name: "#{database_folder_name}/#{FCMPAM_DB_INDEX_NAME}")
  end
end
PAD = PartitionedArrayDatabase

# Path: lib/partitioned_array_database.rb
#a = PAD.new