require_relative 'partitioned_array'
# VERSION: v1.0.2 - more bug fixes, added a few more tests
# VERSION: v1.0.1 - bug fixes
# VERSION: v1.0.0a - fully functional at a basic level; can load archives and the max id of the archive is always available
# VERSION: v0.1.3 - file saving and other methods properly working
# VERSION: v0.1.2 - added managed databases, but need to add more logic to make it work fully
# VERSION: v0.1.1
# UPDATE 8/31/2022: @latest_id increments correctly now
# Manages the @last_entry variable, which tracks where the latest entry is, since PartitionedArray is dynamically allocated.
class ManagedPartitionedArray < PartitionedArray
  attr_accessor :range_arr, :rel_arr, :db_size, :data_arr, :partition_amount_and_offset, :db_path, :db_name, :max_capacity, :has_capacity, :latest_id, :partition_archive_id, :max_partition_archive_id, :db_name_with_no_archive

  # DB_SIZE > PARTITION_AMOUNT
  PARTITION_AMOUNT = 9 # The initial, + 1
  OFFSET = 1 # This came with the math, but you can just state the PARTITION_AMOUNT in total and not worry about the offset in the end
  DB_SIZE = 20 # Caveat: The DB_SIZE is the total # of partitions, but you subtract it by one since the first partition is 0, in code. that is, it is from 0 to DB_SIZE-1, but DB_SIZE is then the max allocated DB size
  PARTITION_ARCHIVE_ID = 0
  DEFAULT_PATH = "./DB_TEST" # default fallSback/write to current path
  DEBUGGING = true
  PAUSE_DEBUG = false
  DB_NAME = 'partitioned_array_slice'  
  PARTITION_ADDITION_AMOUNT = 5
  MAX_CAPACITY = 50
  HAS_CAPACITY = true
  
  # the 'initial' argument variable should be ignored for now, but I had a feeling that there is an elsif that could be implemented at some point
  def initialize(initial: true, max_capacity: MAX_CAPACITY, has_capacity: HAS_CAPACITY, partition_archive_id: PARTITION_ARCHIVE_ID, db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: DEFAULT_PATH, db_name: DB_NAME) 
    if initial #bug: this isn't necessary, but it is a "safeguard(?)" -github copilot 
      # potential to implement more logic here
      @@db_name_with_no_archive = db_name
      @@max_partition_archive_id = 0
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
    @@max_partition_archive_id += 1
    save_partition_archive_id_to_file!
    save_last_entry_to_file!
    save_max_partition_archive_to_file!
    save_max_capacity_to_file!
    save_all_to_files! # PartitionedArray#save_all_to_files!
    temp = ManagedPartitionedArray.new(max_capacity: @max_capacity, initial: false, partition_archive_id: @partition_archive_id, db_size: @db_size, partition_amount_and_offset: @partition_amount_and_offset, db_path: @db_path, db_name: @db_name_with_archive)
    temp.allocate
    return temp
  end

  def save_to_archive!;end
  
  def load_from_archive!(partition_archive_id:)
    temp = ManagedPartitionedArray.new(initial: false, partition_archive_id: partition_archive_id, db_size: @db_size, partition_amount_and_offset: @partition_amount_and_offset, db_path: @db_path, db_name: @db_name_with_archive)
    temp.load_everything_from_files!
    return temp
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

  def load_everything_from_files!
    load_from_files!
    load_last_entry_from_file!
    load_max_partition_archive_from_file!
    load_partition_archive_id_from_file!
    load_max_capacity_from_file!
  end

  def save_everything_to_files!
    save_all_to_files!
    save_last_entry_to_file!
    save_partition_archive_id_to_file!
    save_max_partition_archive_to_file!
    save_max_capacity_to_file!
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

  def save_max_partition_archive_to_file!
    File.open(File.join(@db_path, 'max_partition_archive.json'), 'w') do |file|
      file.write(@@max_partition_archive_id.to_json)
    end
  end

  def load_max_partition_archive_from_file!
    File.open(File.join(@db_path, 'max_partition_archive.json'), 'r') do |file|
      @@max_partition_archive_id = JSON.parse(file.read)
    end
  end

  def save_max_capacity_to_file!
    File.open(File.join(@db_path, 'max_capacity.json'), 'w') do |file|
      file.write(@max_capacity.to_json)
    end
  end

  def load_max_capacity_from_file!
    File.open(File.join(@db_path, 'max_capacity.json'), 'r') do |file|
      @max_capacity = JSON.parse(file.read)
    end
  end

  def db_name_with_archive(db_name: @@db_name_with_no_archive, partition_archive_id: @partition_archive_id)
    return "#{db_name}[#{partition_archive_id}]"
  end
end