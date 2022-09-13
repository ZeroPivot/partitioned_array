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
  DEBUGGING = false
  PAUSE_DEBUG = false
  DB_NAME = 'partitioned_array_slice'  
  PARTITION_ADDITION_AMOUNT = 5
  MAX_CAPACITY = "data_arr_size" # : :data_arr_size; a keyword to add to the array until its full with no buffer additions
  HAS_CAPACITY = true # if false, then the max_capacity is ignored
  
  # the 'initial' argument variable should be ignored for now, but I had a feeling that there is an elsif that could be implemented at some point
  def initialize(partition_addition_amount: PARTITION_ADDITION_AMOUNT, initial: true, max_capacity: MAX_CAPACITY, has_capacity: HAS_CAPACITY, partition_archive_id: PARTITION_ARCHIVE_ID, db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: DEFAULT_PATH, db_name: DB_NAME) 
    #if initial #bug: this isn't necessary, but it is a "safeguard(?)" -github copilot 
      # potential to implement more logic here
      @@db_name_with_no_archive ||= db_name
      @@max_partition_archive_id ||= 0
      #end
      @max_capacity = max_capacity      
      @latest_id = -1# last entry
      @partition_archive_id = partition_archive_id
      @max_capacity = max_capacity_setup!
      @has_capacity = has_capacity
      @partition_addition_amount = partition_addition_amount
      @db_name_with_archive = db_name_with_archive(db_name: @@db_name_with_no_archive, partition_archive_id: @partition_archive_id)    
      @max_capacity = max_capacity_setup!
      @dynamically_allocates = false if @max_capacity == "data_arr_size"

      @dynamically_allocates = true if @max_capacity.is_a? Integer
      p "@max_capacity #{@max_capacity}"
      p "@dynamically_allocates = #{@dynamically_allocates}"
      super(partition_addition_amount: @partition_addition_amount, dynamically_allocates: @dynamically_allocates, db_size: db_size, partition_amount_and_offset: partition_amount_and_offset, db_path: db_path, db_name: @db_name_with_archive)
  end

  # one keyword available: :data_arr_size
  def max_capacity_setup!(db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, max_capacity: MAX_CAPACITY)
    if @max_capacity == "data_arr_size"
      @max_capacity = (0..(db_size * (partition_amount_and_offset))).to_a.size-1
      puts @max_capacity
      @partition_addition_amount = 0
    else
      @max_capacity = max_capacity
    end
  end

  def archive_and_new_db!
    
    save_everything_to_files!
    @partition_archive_id += 1
    @@max_partition_archive_id += 1
    
    
    temp = ManagedPartitionedArray.new(max_capacity: @max_capacity, partition_archive_id: @partition_archive_id, db_size: @db_size, partition_amount_and_offset: @partition_amount_and_offset, db_path: @db_path, db_name: @db_name_with_archive)
    
    
    temp.allocate
    return temp
  end

  def save_to_archive!;end
  
  def load_from_archive!(partition_archive_id:)
    temp = ManagedPartitionedArray.new(max_capacity: @max_capacity, partition_archive_id: partition_archive_id, db_size: @db_size, partition_amount_and_offset: @partition_amount_and_offset, db_path: @db_path, db_name: @db_name_with_archive)
    temp.load_everything_from_files!
    p @data_arr
    return temp

  end

  def each
    @latest_id.times do |i|
      yield @data_arr[i]
    end
  end
  
  def at_capacity?
    puts "max_capacity: #{@max_capacity}"
    case @max_capacity
      when "data_arr_size"
        if @latest_id >= @data_arr.size
          return true
        end
      when Integer
        if ((@latest_id >= @max_capacity) && @has_capacity)
          return true
        end
    end
  end

  def add(return_added_element_id: true, &block)
    
    p @latest_id
    if at_capacity? #guards against adding any additional entries
      return false
    end
    @latest_id += 1
    super(return_added_element_id: return_added_element_id, &block)
  end

  def load_everything_from_files!
    load_from_files! #PartitionedArray#load_from_files!
    load_last_entry_from_file!
    load_max_partition_archive_from_file!
    load_partition_archive_id_from_file!
    load_max_capacity_from_file!
    load_has_capacity_from_file!
    load_db_name_with_no_archive_from_file!
  end

  def save_everything_to_files!
    save_all_to_files! #PartitionedArray#save_all_to_files!
    save_last_entry_to_file!
    save_partition_archive_id_to_file!
    save_max_partition_archive_to_file!
    save_max_capacity_to_file!
    save_has_capacity_to_file!
    save_db_name_with_no_archive_to_file!
  end

  def save_db_name_with_no_archive_to_file!
    File.open(File.join("#{@db_path}/#{@db_name}", "db_name_with_no_archive.json"), "w") do |f|
      f.write(@@db_name_with_no_archive.to_json)
    end
  end

  def load_db_name_with_no_archive_from_file!
    File.open(File.join("#{@db_path}/#{@db_name}", "db_name_with_no_archive.json"), "r") do |f|
      @@db_name_with_no_archive = JSON.parse(f.read)
    end
  end


  def save_has_capacity_to_file!
    File.open(File.join("#{@db_path}/#{@db_name}", "has_capacity.json"), "w") do |f|
      f.write(@has_capacity.to_json)
    end
  end

  def load_has_capacity_from_file!
    File.open(File.join("#{@db_path}/#{@db_name}", "has_capacity.json"), "r") do |f|
      @has_capacity = JSON.parse(f.read)
    end
  end



  def save_last_entry_to_file!
    puts "saving last entry to file"
    puts "latest_id: #{@latest_id}"
    
    if @partition_archive_id == 0
      temp = db_name_with_archive(db_name: @@db_name_with_no_archive, partition_archive_id: @partition_archive_id)
      File.open(File.join("#{@db_path}/#{temp}", 'last_entry.json'), 'w') do |file|
        file.write(@latest_id.to_json)
      end
    else
      temp = db_name_with_archive(db_name: @@db_name_with_no_archive, partition_archive_id: @partition_archive_id-1)
      File.open(File.join("#{@db_path}/#{temp}", 'last_entry.json'), 'w') do |file|
        file.write(@latest_id.to_json)
      end
    end
  end  

  def load_last_entry_from_file!
    File.open(File.join("#{@db_path}/#{@db_name}", 'last_entry.json'), 'r') do |file|
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