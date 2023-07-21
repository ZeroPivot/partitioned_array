require_relative "managed_partitioned_array"
PARTITION_AMOUNT = 2 # The initial, + 1
OFFSET = 1 # This came with the math, but you can just state the PARTITION_AMOUNT in total and not worry about the offset in the end
DB_SIZE = 6 # Caveat: The DB_SIZE is the total # of partitions, but you subtract it by one since the first partition is 0, in code.
#DB_SIZE = 1
PARTITION_ADDITION_AMOUNT = 3
a = ManagedPartitionedArray.new(endless_add: true, has_capacity: false, db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: './db/tests', db_name: 'tests_slice')
a.allocate
a.save_everything_to_files!


1000.times do |i|
  a.add do |entry|
    entry["id"] = i
    entry["name"] = "test"
    entry["age"] = 20
    entry["attributes"] = ["test", "test2"]
  end
end

a.save_everything_to_files!
