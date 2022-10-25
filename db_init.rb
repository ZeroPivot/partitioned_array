require 'json'
require 'fileutils'
require_relative "lib/managed_partitioned_array"
DB_SIZE = 
PARTITION_AMOUNT = 3
OFFSET = 1
DEFAULT_PATH = './db/stress_test'
DB_NAME = 'stress_test'
MAX_CAPACITY=5

FileUtils.rm_rf(DEFAULT_PATH)
db = ManagedPartitionedArray.new(endless_add: true, max_capacity: 99999, has_capacity: false, db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: DEFAULT_PATH, db_name: DB_NAME)
db.allocate
db.save_everything_to_files!
#puts "done!"

#100.times do |i|
#  sl_db.add do |entry|
#    entry["id"] = i
#    entry["data"] = "data"
#    puts "adding entry #{i}"
#    puts "endless add: #{sl_db.endless_add}"
  
    #puts sl_db.partition_addititon_amount
#  end
  
#end
#sl_db.save_everything_to_files!
#s