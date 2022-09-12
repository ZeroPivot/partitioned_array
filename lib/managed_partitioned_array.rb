require_relative 'partitioned_array'
# VERSION: v0.1.3 - file saving and other methods properly working
# VERSION: v0.1.2 - added managed databases, but need to add more logic to make it work fully
# VERSION: v0.1.1
# UPDATE 8/31/2022: @latest_id increments correctly now
# Manages the @last_entry variable, which tracks where the latest entry is, since PartitionedArray is dynamically allocated.
class ManagedPartitionedArray < PartitionedArray
  attr_accessor :range_arr, :rel_arr, :db_size, :data_arr, :partition_amount_and_offset, :db_path, :db_name, :max_capacity, :has_capacity, :latest_id, :partition_archive_id

  # DB_SIZE > PARTITION_AMOUNT
  PARTITION_AMOUNT = 3 # The initial, + 1
  OFFSET = 1 # This came with the math, but you can just state the PARTITION_AMOUNT in total and not worry about the offset in the end
  DB_SIZE = 10 # Caveat: The DB_SIZE is the total # of partitions, but you subtract it by one since the first partition is 0, in code.
  PARTITION_ARCHIVE_ID = 0
  DEFAULT_PATH = "./DB_TEST" # default fallSback/write to current path
  DEBUGGING = true
  PAUSE_DEBUG = false
  DB_NAME = 'partitioned_array_slice'  
  PARTITION_ADDITION_AMOUNT = 3
  MAX_CAPACITY = 100
  HAS_CAPACITY = true

  def db_name_with_archive(db_name: @@db_name_with_no_archive, partition_archive_id: @partition_archive_id)
    return "#{db_name}[#{partition_archive_id}]"
  end

  def initialize(max_capacity: MAX_CAPACITY, has_capacity: HAS_CAPACITY, initial: true, partition_archive_id: PARTITION_ARCHIVE_ID, db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: DEFAULT_PATH, db_name: DB_NAME) 
    if initial
      @@db_name_with_no_archive = db_name
    end
    
    @latest_id = 0 # last entry
    @partition_archive_id = partition_archive_id
    @max_capacity = max_capacity
    @has_capacity = has_capacity
    @db_name_with_archive = db_name_with_archive(db_name: @@db_name_with_no_archive, partition_archive_id: @partition_archive_id)    
    super(db_size: db_size, partition_amount_and_offset: partition_amount_and_offset, db_path: db_path, db_name: @db_name_with_archive)
  end

  def archive_and_new_db!
    @partition_archive_id += 1
    save_partition_archive_id_to_file!
    save_last_entry_to_file!
    save_all_to_files!
  
    return ManagedPartitionedArray.new(initial: false, partition_archive_id: @partition_archive_id, db_size: @db_size, partition_amount_and_offset: @partition_amount_and_offset, db_path: @db_path, db_name: @db_name_with_archive)
  end

  def each
    @latest_id.times do |i|
      yield @data_arr[i]
    end
  end
  
  def at_capacity?
    if ((@latest_id >= @max_capacity-1) && @has_capacity)
      return true
    else
      return false
    end
  end

  def add(return_added_element_id: true, &block)
    if at_capacity? #guards against adding any additional entries
      return false
    else
      @latest_id += 1
    end
    super(return_added_element_id: return_added_element_id, &block)
  end

  def save_last_entry_to_file!
    File.open(File.join("#{@db_path}/#{@db_name}", @@db_name_with_no_archive + '_last_entry.json'), 'w') do |file|
      file.write(@latest_id.to_json)
    end
  end
  

  def load_last_entry_from_file!
    File.open(File.join("#{@db_path}/#{@db_name}", @@db_name_with_no_archive + '_last_entry.json'), 'r') do |file|
      @latest_id = JSON.parse(file.read)
    end
  end

  def save_partition_archive_id_to_file!
    File.open(File.join(@db_path, 'partition_archive_id.json'), 'w') do |file|
      file.write(@partition_archive_id.to_json)
    end
  end

  def load_partition_archive_id_from_file!
    File.open(File.join(@db_path, 'partition_archive_id.json'), 'r') do |file|
      @partition_archive_id = JSON.parse(file.read)
    end
  end

end

