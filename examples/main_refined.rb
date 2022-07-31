require_relative 'partitioned_array'
require_relative 'visuals'

# Create a new data structure and allocate the partition to memory
partitioned_array = PartitionedArray.new
partitioned_array.allocate

#Returns the partition elements within the first partition within @data_arr; returns a hash of relevant data if argument is true (optional)
# Examples
id = 0
p "First Partition in @data_arr: #{partitioned_array.get_partition(id)}" # get a partition (a chunk) of a partition element withinn @data_arr
p "First Element in @data_arr: #{partitioned_array.get(id)}" # gets an entry from @data_arr directly
puts


# Set an element within @data_arr; ignores partitions and goes for raw ids

partitioned_array.set(id) do |hash|
   hash["first"] = "1st"   
end

partitioned_array.set(id + 1) do |hash|
    hash["second"] = "2nd"
end

# add a partition to the @range_arr; @data_arr, add partition_amount_and\offset to @rel_arr, @db_size increases by one
partitioned_array.add_partition 
partitioned_array.add_partition

allocate_ranges_sequentially(partitioned_array)

partitioned_array.add_partition

last_element = -1
partitioned_array.set(last_element) do |hash|
    hash["last"] = "Nth"
end


# All that has to be done to store the PartitionedArray instance data
=begin
PartitionedArray#load_from_json!()
PartitionedArray#dump_to_json!
PartitionedArray#save_partition_to_file!
PartitionedArray#load_partition_from_file!
=end


# Test to see if file loading and unloading creates equivalent data structures
puts "Before:"

p partitioned_array.data_arr
p partitioned_array.partition_amount_and_offset
p partitioned_array.range_arr
p partitioned_array.rel_arr

_data_arr = partitioned_array.data_arr
_partition_amount_and_offset = partitioned_array.partition_amount_and_offset
_range_arr = partitioned_array.range_arr
_rel_arr = partitioned_array.rel_arr

partitioned_array.dump_to_json!
partitioned_array.load_from_json!

# assert tests
p "@data_arr remains the same: #{partitioned_array.data_arr == _data_arr}"
p "@partition_amount_and_offset: #{partitioned_array.partition_amount_and_offset == _partition_amount_and_offset}"
p "@range_arr: #{partitioned_array.range_arr == _range_arr}"
p "@rel_arr: #{partitioned_array.rel_arr == _rel_arr}"

p "Get a certain slice of @data_arr (0..4): #{partitioned_array.data_arr[0..4]}"
p "Load partition data into @data_arr (0th): #{partitioned_array.load_partition_from_file!(0)}"



partitioned_array.save_partition_to_file!(0)

# PartitionedArray#set_partition_subelement(id, partition_id, &block)
success = partitioned_array.set_partition_subelement(0, 0) do |hash|
  hash[:modified] = "0, 0"
end
p "successfully modified partition subelement: #{success}"
p "New @data_arr: #{partitioned_array.data_arr}"

