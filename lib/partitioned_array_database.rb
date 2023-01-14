require_relative 'file_context_managed_partitioned_array_manager'
# VERSION v0.0.5 - alias db pad
# VERSION v0.0.4 - sync with LineDB
# VERSION v0.0.3 - cleanup
# VERSION 0.0.2 - Database creation by superfolder
# VERSION 0.0.1 - Skeleton of the class created

class PartitionedArrayDatabase
  attr_accessor :database_folder_name, :pad
  FCMPAM_DB_INDEX_NAME = 'FCMPAM_DB_INDEX'
  DB_NAME = 'FCMPAM_DB'
  PARTITION_AMOUNT = 20
  ENDLESS_ADD = true
  HAS_CAPACITY = true
  DB_SIZE = 200
  DYNAMICALLY_ALLOCATES = true
  TRAVERSE_HASH = true

  LABEL_INTEGER = false
  LABEL_RANGES = false

  DATABASE_FOLDER_NAME = './default' # folder name in terms of a full or relative path  
  FCMPAM = FileContextManagedPartitionedArrayManager
  # For a change of database variables, check the file constants in the file_context_managed_partitioned_array_manager.rb library, etc.
  def initialize(label_integer: LABEL_INTEGER, label_ranges: LABEL_RANGES, traverse_hash: TRAVERSE_HASH, partition_amount: PARTITION_AMOUNT, database_folder_name: DATABASE_FOLDER_NAME, endless_add: ENDLESS_ADD, has_capacity: DB_HAS_CAPACITY, dynamically_allocates: DYNAMICALLY_ALLOCATES, db_size: DATABASE_SIZE)
    @database_folder_name = database_folder_name
    @endless_add = endless_add
    @has_capacity = has_capacity
    @db_size = db_size
    @partition_amount = partition_amount
    @dynamically_allocates = dynamically_allocates
    @traverse_hash = traverse_hash 
    @label_integer = label_integer
    @label_ranges = label_ranges  
    @pad = FCMPAM.new(label_integer: @label_integer, label_ranges: @label_ranges, traverse_hash: @traverse_hash, db_partition_amount_and_offset: @partition_amount, db_has_capacity: @has_capacity, db_dynamically_allocates: @dynamically_allocates, db_size: @db_size, db_path: "#{database_folder_name}/#{DB_NAME}", fcmpa_db_folder_name: "#{database_folder_name}/#{FCMPAM_DB_INDEX_NAME}")
  end
  def pad
    
    #puts pad.traverse_hash
    #p @pad.traverse_hash
    @pad

  end

  alias db pad
  alias DB pad
  alias PAD pad
  alias d pad
end
PAD = PartitionedArrayDatabase

# Path: lib/partitioned_array_database.rb
#a = PAD.new