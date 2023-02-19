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

500.times do |i|
  sl_db.add do |hash|
    hash["data_arr_size"] = 0
    #puts "added #{i}"
  end
  end

  sl_db.save_everything_to_files!
  sl_db.archive_and_new_db!
  sl_db.allocate
  sl_db.save_everything_to_files!