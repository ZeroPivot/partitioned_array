require 'json'
require 'securerandom'
require_relative 'lib/managed_partitioned_array'
DB_SIZE = 20
PARTITION_AMOUNT = 9
OFFSET = 1
DEFAULT_PATH = './stress_test'
DB_NAME = 'stress_test'

a = ManagedPartitionedArray.new(db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: DEFAULT_PATH, db_name: DB_NAME)

a.allocate
a.save_all_to_files!
a.load_from_files!
p a.data_arr
#50_000.times do |i|
0.upto(2) do |i|
  p a
  
  until (a.at_capacity?)
    a.add do |entry|
      puts "adding entry #{i}"
      entry["uuid"] = SecureRandom.uuid
      entry["id"] = i
      entry["random_number"] = rand(10000)
      #break
    end
  end
  a = a.archive_and_new_db! unless i==2
  a.allocate unless i == 2
  
end
a.save_all_to_files!
#p a.get(0)

#p a.get(0)