require 'json'
require 'fileutils'
require_relative "lib/managed_partitioned_array"
DB_SIZE = 20
PARTITION_AMOUNT = 14
OFFSET = 1
DEFAULT_PATH = './stress_test'
DB_NAME = 'stress_test'

FileUtils.rm_rf(DEFAULT_PATH)
sl_db = ManagedPartitionedArray.new(db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: DEFAULT_PATH, db_name: DB_NAME)
sl_db.allocate
p sl_db.save_all_to_files!
sl_db.load_from_files!
sl_db.save_last_entry_to_file!
puts "done?"