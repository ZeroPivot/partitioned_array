require_relative 'partitioned_array'

# VERSION: v0.1.0
# Manages the @last_entry variable, which tracks where the latest entry is, since PartitionedArray is dynamically allocated.
class ManagedPartitionedArray < PartitionedArray
  attr_accessor :last_entry

  def initialize(db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: DEFAULT_PATH, db_name: DB_NAME) 
    @last_entry = 0
    super(db_size: db_size, partition_amount_and_offset: partition_amount_and_offset, db_path: db_path, db_name: db_name)
  end

  def save_last_entry_to_file!
    File.open(File.join(@db_path, @db_name + '_last_entry.json'), 'w') do |file|
      file.write(@last_entry.to_json)
    end
  end

  def load_last_entry_from_file!
    File.open(File.join(@db_path, @db_name + '_last_entry.json'), 'r') do |file|
      @last_entry = JSON.parse(file.read)
    end
  end

end

