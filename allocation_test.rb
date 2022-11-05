require 'json'
require 'fileutils'
require_relative "lib/managed_partitioned_array"
PARTITION_AMOUNT = 2 # The initial, + 1
OFFSET = 1 # This came with the math, but you can just state the PARTITION_AMOUNT in total and not worry about the offset in the end
DB_SIZE = 6 # Caveat: The DB_SIZE is the total # of partitions, but you subtract it by one since the first partition is 0, in code.
#DB_SIZE = 1
PARTITION_ADDITION_AMOUNT = 5





#FileUtils.rm_rf('./db/sl')
#sl_db = ManagedPartitionedArray.new(max_capacity: "data_arr_size", has_capacity: true, db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: './db/sl', db_name: 'sl_slice')
#sl_db.allocate
#sl_db.save_everything_to_files!


FileUtils.rm_rf('./db/tests')

db_tests = ManagedPartitionedArray.new(endless_add: true, has_capacity: false, db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: './db/tests', db_name: 'tests_slice')
db_tests.allocate
db_tests.save_everything_to_files!
puts "Allocation and file creation complete"
gets # at the blank file stage
=begin
id = db_tests.add do |entry|
  entry["id"] = 0
end
part = db_tests.get(id, hash: true)['db_index']
puts db_tests.get(id)
db_tests.save_partition_to_file!(part)

id = db_tests.add do |entry|
  entry["id"] = 1
end
part = db_tests.get(id, hash: true)['db_index']
puts db_tests.get(id)
db_tests.save_partition_to_file!(part)

id = db_tests.add do |entry|
  entry["id"] = 2
end
part = db_tests.get(id, hash: true)['db_index']
puts db_tests.get(id)
db_tests.save_partition_to_file!(part)







id = db_tests.add do |entry|
  entry["id"] = 3
end
part = db_tests.get(id, hash: true)['db_index']
puts db_tests.get(id)
db_tests.save_partition_to_file!(part)






id = db_tests.add do |entry|
  entry["id"] = 4
end
part = db_tests.get(id, hash: true)['db_index']
puts db_tests.get(id)
db_tests.save_partition_to_file!(part)
200.times do
  puts "adding an entry"
  #var = gets
  id = db_tests.add do |entry|
    entry["id"] = id
  end
  part = db_tests.get(id, hash: true)['db_index']
  puts db_tests.get(id)
  db_tests.save_partition_to_file!(part)

end


db_tests = db_tests.archive_and_new_db!
db_tests.save_everything_to_files!
db_tests = db_tests.archive_and_new_db!()
db_tests.save_everything_to_files!

db_tests = db_tests.load_from_archive!(partition_archive_id: 0)

69.times do |i|
  db_tests.add do |entry|
    entry["id"] = "#{i} - adding up first partition and saving to see the difference"
    end
end

db_tests.save_everything_to_files!
=end