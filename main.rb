require_relative 'partitioned_array'
require 'fileutils'
require 'json'


# set_partition_subelement(id, partition_id, &block)
# get_partition_subelement(id, partition_id)
# get_parttion(partition_id)
# set(id, &block)
# allocate 
# get(id, hash: false)
# add_partition

# load_from_json!

# pure_dump_to_json!(db_folder: folder)  - unfinished
# pure_load_from_json! (unfinished)
# pure_load_partition_from_file!(partition_id)
# pure_save_partition_to_file!(partition_id)

# load_partition_from_file!(partition_id)
# save_partitiohn_to_file!(partition_id)


# dump_to_json!(db_folder: folder)






y = PartitionedArray.new
y.allocate
p y.pure_load_partition_from_file!(0)
p y.load_partition_from_file!(0)

y.set_partition_subelement(0, -1) do |partition_subelement|
  partition_subelement["test"] = { "test" => "test" }
end

p y.get_partition_subelement(0, 0)

exit
p y.get_partition 0
y.add_partition

y.set(0) do |i| 
 # i["lol"] = "lol"
 # i["lol2"] = "lol2"
end

p y.get_partition(-1)
p y.get_partition(0)


=begin
y.set_partition_subelement(3, 0) do |partition_subelement|
  partition_subelement[:lol567567] = "lol"
  puts "lol"
end
=end

#p y.get_partition(-1)

#p y.data_arr

# Visuals
def allocate_ranges_sequentially(partitioned_array)
  range_arr = partitioned_array.range_arr
  range_arr.each_with_index do |range, range_index|
    range.to_a.each_with_index do |range_element, range_element_index|
      partitioned_array.set_partition_subelement!(range_element_index, range_index) do |partition_subelement|
        partition_subelement["id"] = range_index
      end
    end
  end
  partitioned_array.data_arr
end



p = PartitionedArray.new()


=begin
p allocate_ranges_sequentially(y)

puts "Before:"
p y.data_arr
p y.partition_amount_and_offset
p y.range_arr
p y.rel_arr

_data_arr = y.data_arr
_partition_amount_and_offset = y.partition_amount_and_offset
_range_arr = y.range_arr
_rel_arr = y.rel_arr

y.dump_to_json!
y.load_from_json!


p y.data_arr == _data_arr
p y.partition_amount_and_offset == _partition_amount_and_offset
p y.range_arr == _range_arr
p y.rel_arr  == _rel_arr

p y.data_arr[0..77]
y.load_partition_from_file!(0)
y.load_partition_from_file!(0)
p y.data_arr[0..77]

y.save_partition_to_file!(60)
=end