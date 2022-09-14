

require_relative 'lib/managed_partitioned_array'
require 'json'
require 'securerandom'

DB_SIZE = 5
PARTITION_AMOUNT = 3
OFFSET = 1
DEFAULT_PATH = './db/stress_test'
DB_NAME = 'stress_test'




FileUtils.rm_rf(DEFAULT_PATH)
sl_db = ManagedPartitionedArray.new(max_capacity: "data_arr_size", has_capacity: true, db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: DEFAULT_PATH, db_name: DB_NAME)

sl_db.allocate
sl_db.save_everything_to_files!
puts "done!"



a = ManagedPartitionedArray.new(max_capacity: "data_arr_size", has_capacity: true, db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: DEFAULT_PATH, db_name: DB_NAME)

a.load_everything_from_files!
a = a.load_from_archive!
entry = a.add(return_added_element_id: true) do |hash|
  hash[:id] = SecureRandom.uuid
  hash[:data] = SecureRandom.uuid
end

p entry

#p a.partition_addition_amount
#p a.data_arr
#50_000.times do |i|

0.upto(9) do |i|
 # p a
  puts a.max_capacity
  until (a.at_capacity?)
    a.add do |entry|
      puts "adding entry #{i}"     
      entry["id_chunk"] = i
      entry["random_number"] = rand(10000)
      #break
    end
  end
  a = a.archive_and_new_db! if a.at_capacity?
end
#p = a.add do |entry|
#  entry["final entry"] = "final entry"
#end

#a.add do |entry|
#  entry["final entry"] = "final entry"
#end
a.save_everything_to_files! 
entry = a.add do |hash|
  hash[:id] = "jumbled, wont save to disc"
  hash[:data] = "you know it"
end


puts "entry: #{entry}"
puts "#{a.get(entry, hash: true)["db_index"]}"
a.save_partition_to_file!(a.get(entry, hash: true)["db_index"])
#p a.get(0)
#a = a.load_from_archive!(partition_archive_id: 0)
#a.set(0) do |entry|
#  entry["final entry"] = "set 0"
#  puts "did it set?"
#end
#p a.data_arr.size
#p a.partition_addition_amount

#p a.get(0)

# make a new directory



