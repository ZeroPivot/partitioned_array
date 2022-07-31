require 'json'
require_relative 'managed_partitioned_array'
DB_SIZE = 6
PARTITION_AMOUNT = 3
OFFSET = 1


a = ManagedPartitionedArray.new(db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: '../../sl_api_db', db_name: 'sl_api_db')

a.allocate
a.load_from_files!
p a.data_arr
a.add do |entry|
  entry[:log] = "Hello World"
end
a.save_all_to_files!
#p a.get(0)