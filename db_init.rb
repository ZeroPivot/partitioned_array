require 'json'
LATEST_PA_VERSION = "v1.2.3"
require_relative "lib/managed_partitioned_array"
PARTITION_AMOUNT = 9 # The initial, + 1 
OFFSET = 1 # This came with the math, but you can just state the PARTITION_AMOUNT in total and not worry about the offset in the end
DB_SIZE = 20 # Caveat: The DB_SIZE is th# Caveat: The DB_SIZE is the total # of partitions, but you subtract it by one since the first partition is 0, in code.
PARTITION_ADDITION_AMOUNT = 5 # original, but we're changing it
PARTITION_ADDITION_AMOUNT_SL = 150

# Q: how do I git commit?
# A: git add . && git commit -m "message" && git push

# Q: how do I git pull?
# A: git pull

# Q: how do I git clone?
# A: git clone



FileUtils.rm_rf('./db/sl')

sl_db = ManagedPartitionedArray.new(partition_addition_amount: PARTITION_ADDITION_AMOUNT_SL, max_capacity: "data_arr_size", has_capacity: true, db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: './db/sl', db_name: 'sl_slice')
sl_db.allocate
sl_db.save_everything_to_files!
5.times do |i|
sl_db.add do |hash|
  hash["data_arr_size"] = 0
  puts "added #{i}"
end
end
p sl_db.get(0)
sl_db.save_everything_to_files!
sl_db = sl_db.archive_and_new_db!
sl_db.allocate



5.times do |i|
  sl_db.add do |hash|
    hash["data_arr_size"] = 0
    puts "added #{i}"
  end
  end
  sl_db.save_everything_to_files!
  sl_db = sl_db.archive_and_new_db!
  sl_db.allocate
  sl_db.save_everything_to_files!
## URL SHORTENING
 #FileUtils.rm_rf('./db/url_shorten')
 #db_tests = ManagedPartitionedArray.new(endless_add: true, has_capacity: false, db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: './db/url_shorten', db_name: 'url_slice')
 #db_tests.allocate
 #db_tests.save_everything_to_files!


#db_tests = ManagedPartitionedArray.new(db_path: "./db/sl", db_name: 'sl_slice')
#db_tests.allocate
#db_tests.save_everything_to_files!
#puts "Allocation and file creation complete"

