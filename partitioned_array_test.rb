require 'json'
require 'securerandom'
require_relative 'lib/managed_partitioned_array'
DB_SIZE = 5
PARTITION_AMOUNT = 3
OFFSET = 1
DEFAULT_PATH = './db/stress_test'
DB_NAME = 'stress_test'

a = ManagedPartitionedArray.new(max_capacity: "data_arr_size", has_capacity: true, db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: DEFAULT_PATH, db_name: DB_NAME)
a.allocate
a.save!
a.load_everything_from_files!
entry = a.add(return_added_element_id: true) do |hash|
  hash[:id] = SecureRandom.uuid
  hash[:data] = SecureRandom.uuid
end

p entry

#p a.partition_addition_amount
#p a.data_arr
#50_000.times do |i|

0.upto(999) do |i|
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
  hash["id"] = "jumbled, wont save to disc"
  hash["data"] = "you know it"
end


puts "entry: #{entry}"
puts "#{a.get(entry, hash: true)["db_index"]}"
puts "#{a.get(entry, hash: true)["data"]}"
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
require_relative 'lib/managed_partitioned_array'

# Test case 1: Verify that ManagedPartitionedArray can be instantiated
def test_managed_partitioned_array_instantiation
  a = ManagedPartitionedArray.new(max_capacity: "data_arr_size", has_capacity: true, db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: DEFAULT_PATH, db_name: DB_NAME)
  assert_instance_of ManagedPartitionedArray, a
end

# Test case 2: Verify that an element can be added to the array
def test_add_element_to_array
  a = ManagedPartitionedArray.new(max_capacity: "data_arr_size", has_capacity: true, db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: DEFAULT_PATH, db_name: DB_NAME)
  a.allocate
  a.save!
  a.load_everything_from_files!
  entry = a.add(return_added_element_id: true) do |hash|
    hash[:id] = SecureRandom.uuid
    hash[:data] = SecureRandom.uuid
  end
  assert_not_nil entry
end

# Test case 3: Verify that the array can reach its maximum capacity and allocate more partitions dynamically
def test_dynamic_partition_allocation
  a = ManagedPartitionedArray.new(max_capacity: "data_arr_size", has_capacity: true, db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: DEFAULT_PATH, db_name: DB_NAME)
  a.allocate
  a.save!
  a.load_everything_from_files!
  0.upto(999) do |i|
    until a.at_capacity?
      a.add do |entry|
        entry["id_chunk"] = i
        entry["random_number"] = rand(10000)
      end
    end
    a = a.archive_and_new_db! if a.at_capacity?
  end
  assert_equal PARTITION_AMOUNT + OFFSET + 1000, a.partition_amount_and_offset
end

# Test case 4: Verify that an element can be retrieved from the array
def test_retrieve_element_from_array
  a = ManagedPartitionedArray.new(max_capacity: "data_arr_size", has_capacity: true, db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: DEFAULT_PATH, db_name: DB_NAME)
  a.allocate
  a.save!
  a.load_everything_from_files!
  entry = a.add do |hash|
    hash["id"] = "jumbled, wont save to disc"
    hash["data"] = "you know it"
  end
  retrieved_entry = a.get(entry, hash: true)
  assert_equal "jumbled, wont save to disc", retrieved_entry["id"]
  assert_equal "you know it", retrieved_entry["data"]
end

# Test case 5: Verify that a partition can be saved to a file
def test_save_partition_to_file
  a = ManagedPartitionedArray.new(max_capacity: "data_arr_size", has_capacity: true, db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: DEFAULT_PATH, db_name: DB_NAME)
  a.allocate
  a.save!
  a.load_everything_from_files!
  entry = a.add do |hash|
    hash["id"] = "jumbled, wont save to disc"
    hash["data"] = "you know it"
  end
  a.save_partition_to_file!(a.get(entry, hash: true)["db_index"])
  assert File.exist?("#{DEFAULT_PATH}/#{DB_NAME}_#{a.get(entry, hash: true)["db_index"]}.json")
end

# Run the test cases
test_managed_partitioned_array_instantiation
test_add_element_to_array
test_dynamic_partition_allocation
test_retrieve_element_from_array
test_save_partition_to_file
