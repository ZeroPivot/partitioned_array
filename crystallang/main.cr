# require partitioned_array
require "json"
require "big"
require "file_utils"
require "./partitioned_array"
require "./managed_partitioned_array"
 # DB_SIZE > PARTITION_AMOUNT
 PARTITION_AMOUNT = 9 # The initial, + 1
 OFFSET = 1 # This came with the math, but you can just state the PARTITION_AMOUNT in total and not worry about the offset in the end
 DB_SIZE = 20 # Caveat: The DB_SIZE is the total # of partitions, but you subtract it by one since the first partition is 0, in code. that is, it is from 0 to DB_SIZE-1, but DB_SIZE is then the max allocated DB size
 PARTITION_ARCHIVE_ID = 0
 DEFAULT_PATH = "./DB_TEST" # default fallback/write to current path
 DEBUGGING = false
 PAUSE_DEBUG = false
 DB_NAME = "partitioned_array_slice"
 PARTITION_ADDITION_AMOUNT = 1
 MAX_CAPACITY = "data_arr_size" # : :data_arr_size; a keyword to add to the array until its full with no buffer additions
 HAS_CAPACITY = true # if false, then the max_capacity is ignored and at_capacity? raises if @has_capacity == false
 DYNAMICALLY_ALLOCATES = true
 ENDLESS_ADD = false
#   def initialize(endless_add: ENDLESS_ADD, dynamically_allocates: DYNAMICALLY_ALLOCATES, 
# partition_addition_amount: PARTITION_ADDITION_AMOUNT, max_capacity: MAX_CAPACITY,
# has_capacity: HAS_CAPACITY, partition_archive_id: PARTITION_ARCHIVE_ID,
# db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET,
# db_path: DEFAULT_PATH, db_name: DB_NAME) 
a = ManagedPartitionedArray.new
puts a.allocate
puts a.data_arr
#a.add do |hash|
#  "hmm"#hash["k"] = { "k" => "v" }
#end
#puts a.data_arr
a.save_everything_to_files!
# create a partitioned array with 10 partitions

