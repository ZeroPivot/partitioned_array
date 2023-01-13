require_relative 'file_context_managed_partitioned_array_manager'
# VERSION v0.0.4 - experimentation with the database
# VERSION v0.0.3 - cleanup
# VERSION 0.0.2 - Database creation by superfolder
# VERSION 0.0.1 - Skeleton of the class created

class PartitionedArrayDatabase
  attr_accessor :database_folder_name, :pad
  FCMPAM_DB_INDEX_NAME = 'FCMPAM_DB_INDEX'
  DB_NAME = 'FCMPAM_DB'
  DATABASE_FOLDER_NAME = './default' # folder name in terms of a full or relative path
  FCMPAM = FileContextManagedPartitionedArrayManager
  # For a change of database variables, check the file constants in the file_context_managed_partitioned_array_manager.rb library, etc.
  def initialize(database_folder_name: DATABASE_FOLDER_NAME)
    @database_folder_name = database_folder_name  
    @pad = FCMPAM.new(db_path: "#{database_folder_name}/#{DB_NAME}", fcmpa_db_folder_name: "#{database_folder_name}/#{FCMPAM_DB_INDEX_NAME}")    
  end
end
PAD = PartitionedArrayDatabase

# Path: lib/partitioned_array_database.rb
a = PAD.new