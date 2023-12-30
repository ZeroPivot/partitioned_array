require_relative "partitioned_array"
require_relative "json_eval"
test = PartitionedArray.new
test.allocate

p test.pure_load_partition_from_file!(1)
p test.data_arr
p test.pure_save_partition_to_file!(1)
p test.pure_load_partition_from_file!(1)
p test.data_arr
