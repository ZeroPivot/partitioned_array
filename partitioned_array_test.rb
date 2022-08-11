require 'json'
require_relative 'lib/managed_partitioned_array'
DB_SIZE = 3
PARTITION_AMOUNT = 3
OFFSET = 1
DEFAULT_PATH = './sl_api_db'
DB_NAME = 'sl_api_db'


a = ManagedPartitionedArray.new(db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: './sl_api_db', db_name: 'sl_api_db')

a.allocate
a.load_from_files!
p a.data_arr
a.add do |entry|
  puts "adding entry: #{entry}"
  entry["a"] = rand(100)
  #break
end
a.save_all_to_files!
#p a.get(0)
#p a.get(0)