require 'json'
require 'securerandom'
require_relative 'lib/managed_partitioned_array'
DB_SIZE = 20
PARTITION_AMOUNT = 4
OFFSET = 1
DEFAULT_PATH = './stress_test'
DB_NAME = 'stress_test'

a = ManagedPartitionedArray.new(db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: DEFAULT_PATH, db_name: DB_NAME)

a.load_everything_from_files!
p a.data_arr
#50_000.times do |i|
0.upto(10) do |i|
  p a
  
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
a.save_everything_to_files!


#p a.get(0)

#p a.get(0)