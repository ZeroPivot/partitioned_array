require "./partitioned_array"
require "json"
require "file_utils"

class ManagedPartitionedArray < PartitionedArray
  property endless_add : Bool
  property max_capacity : (String | Int32)
  property has_capacity : Bool
  property latest_id : Int32
  property partition_archive_id : Int32
  property max_partition_archive_id : Int32
  property original_db_name : String
  property db_name_with_archive : String
  property basedir_created : Bool
  
  # Constants
  ENDLESS_ADD = false
  MAX_CAPACITY = "data_arr_size"
  HAS_CAPACITY = true
  PARTITION_ARCHIVE_ID = 0
  
  def initialize(
    label_integer = LABEL_INTEGER,
    label_ranges = LABEL_RANGES,
    endless_add = ENDLESS_ADD,
    dynamically_allocates = DYNAMICALLY_ALLOCATES,
    partition_addition_amount = PARTITION_ADDITION_AMOUNT,
    max_capacity = MAX_CAPACITY,
    has_capacity = HAS_CAPACITY,
    partition_archive_id = PARTITION_ARCHIVE_ID,
    db_size = DB_SIZE,
    partition_amount_and_offset = PARTITION_AMOUNT + OFFSET,
    db_path = DEFAULT_PATH,
    db_name = "partitioned_array_slice"
  )
    @db_path = db_path
    @db_size = db_size
    @db_name = db_name
    @partition_amount_and_offset = partition_amount_and_offset
    @partition_archive_id = partition_archive_id
    @original_db_name = strip_archived_db_name(db_name: db_name)
    @db_name_with_archive = db_name_with_archive(db_name: @original_db_name, partition_archive_id: @partition_archive_id)
    @max_capacity = max_capacity
    @latest_id = 0
    @has_capacity = has_capacity
    @max_partition_archive_id = initialize_max_partition_archive_id2!
    @partition_addition_amount = partition_addition_amount
    @max_capacity = max_capacity_setup!
    @dynamically_allocates = dynamically_allocates
    @endless_add = endless_add
    @label_integer = label_integer
    @label_ranges = label_ranges
    @basedir_created = false
    
    super(
      label_integer: @label_integer,
      label_ranges: @label_ranges, 
      partition_addition_amount: @partition_addition_amount,
      dynamically_allocates: @dynamically_allocates,
      db_size: @db_size,
      partition_amount_and_offset: @partition_amount_and_offset,
      db_path: @db_path,
      db_name: @db_name_with_archive
    )
  end
  
  def max_capacity_setup!
    if @max_capacity == "data_arr_size"
      "data_arr_size"
    else
      @max_capacity
    end
  end
  
  def at_capacity?
    return false unless @has_capacity
    
    if @max_capacity == "data_arr_size"
      @latest_id >= (@db_size * @partition_amount_and_offset) - 1
    else
      max_cap = @max_capacity.is_a?(Int32) ? @max_capacity.as(Int32) : 0
      @latest_id >= max_cap
    end
  end
  
  def create_basedir_once!
    if !@basedir_created
      create_basedir!
      @basedir_created = true
    end
  end
  
  def create_basedir!
    FileUtils.mkdir_p(@db_path)
  end
  
  def save_everything_to_files!
    create_basedir_once!
    save_all_to_files!
    save_last_entry_to_file!
    save_partition_archive_id_to_file!
    save_max_partition_archive_id_to_file!
    save_max_capacity_to_file!
    save_has_capacity_to_file!
    save_db_name_with_no_archive_to_file!
    save_partition_addition_amount_to_file!
    save_endless_add_to_file!
  end
  
  def archive_and_new_db!(
    label_integer = @label_integer,
    label_ranges = @label_ranges,
    auto_allocate = true,
    partition_addition_amount = @partition_addition_amount,
    max_capacity = @max_capacity,
    has_capacity = @has_capacity,
    db_size = @db_size,
    partition_amount_and_offset = @partition_amount_and_offset,
    db_path = @db_path,
    db_name = @db_name_with_archive
  )
    save_everything_to_files!
    @partition_archive_id += 1
    increment_max_partition_archive_id!
    
    temp = ManagedPartitionedArray.new(
      partition_addition_amount: partition_addition_amount,
      has_capacity: has_capacity,
      label_integer: label_integer,
      label_ranges: label_ranges,
      max_capacity: max_capacity, 
      partition_archive_id: @partition_archive_id,
      db_size: db_size,
      partition_amount_and_offset: partition_amount_and_offset,
      db_path: db_path,
      db_name: db_name
    )
    
    temp.allocate if auto_allocate
    temp
  end
  
  def add(return_added_element_id = true, save_on_partition_add = true, save_last_entry_to_file = true)
    if @endless_add && @latest_id + 1 >= @data_arr.size * @partition_amount_and_offset
      add_partition
      
      partition_to_save = get(@latest_id + 1, true)["db_index"].as(Int32)
      save_partition_to_file!(partition_to_save) if save_on_partition_add
    elsif at_capacity?
      return false
    end
    
    @latest_id += 1
    save_last_entry_to_file! if save_last_entry_to_file
    
    if block_given?
      super(return_added_element_id) { |entry| yield entry }
    else
      super(return_added_element_id)
    end
  end
  
  def save_last_entry_to_file!
    dir_path = File.join("#{@db_path}/#{db_name_with_archive(db_name: @original_db_name)}")
    FileUtils.mkdir_p(dir_path)
    
    File.open(File.join(dir_path, "last_entry.json"), "w") do |file|
      file.write(@latest_id.to_json)
    end
  end
  
  def load_last_entry_from_file!
    File.open(File.join("#{@db_path}/#{db_name_with_archive(db_name: @original_db_name)}", "last_entry.json"), "r") do |file|
      @latest_id = JSON.parse(file.read).as_i
    end
  end
  
  def save_partition_archive_id_to_file!
    File.open(File.join("#{@db_path}/#{db_name_with_archive(db_name: @original_db_name)}", "partition_archive_id.json"), "w") do |file|
      file.write(@partition_archive_id.to_json)
    end
  end
  
  def load_partition_archive_id_from_file!
    File.open(File.join("#{@db_path}/#{db_name_with_archive(db_name: @original_db_name)}", "partition_archive_id.json"), "r") do |file|
      @partition_archive_id = JSON.parse(file.read).as_i
    end
  end
  
  def initialize_max_partition_archive_id2!
    if File.exists?(File.join(@db_path, "max_partition_archive_id.json"))
      File.open(File.join(@db_path, "max_partition_archive_id.json"), "r") do |f|
        JSON.parse(f.read).as_i
      end
    else
      0
    end
  end
  
  def save_max_partition_archive_id_to_file!
    File.open(File.join(@db_path, "max_partition_archive_id.json"), "w") do |file|
      file.write(@max_partition_archive_id.to_json)
    end
  end
  
  def load_max_partition_archive_id_from_file!
    if File.exists?(File.join(@db_path, "max_partition_archive_id.json"))
      File.open(File.join(@db_path, "max_partition_archive_id.json"), "r") do |file|
        @max_partition_archive_id = JSON.parse(file.read).as_i
      end
    else
      FileUtils.touch(File.join(@db_path, "max_partition_archive_id.json"))
      File.open(File.join(@db_path, db_name_with_archive(db_name: @db_name, partition_archive_id: @partition_archive_id)), "w") do |file|
        file.write(0.to_json)
      end
      0
    end
  end
  
  def increment_max_partition_archive_id!
    @max_partition_archive_id += 1
    File.open("#{@db_path}/max_partition_archive_id.json", "w") do |f|
      f.write(@max_partition_archive_id.to_json)
    end
  end
  
  def db_name_with_archive(db_name : String = @original_db_name, partition_archive_id : Int32 = @partition_archive_id)
    "#{db_name}[#{partition_archive_id}]"
  end
  
  def strip_archived_db_name(db_name : String = @original_db_name)
    db_name.gsub(/\[.+\]/, "")
  end
  
  def save_max_capacity_to_file!
    File.open(File.join(@db_path, "max_capacity.json"), "w") do |file|
      file.write(@max_capacity.to_json)
    end
  end
  
  def load_max_capacity_from_file!
    File.open(File.join(@db_path, "max_capacity.json"), "r") do |file|
      raw_value = JSON.parse(file.read)
      @max_capacity = raw_value.as_s? || raw_value.as_i
    end
  end
  
  def save_has_capacity_to_file!
    File.open(File.join("#{@db_path}/#{@db_name}", "has_capacity.json"), "w") do |f|
      f.write(@has_capacity.to_json)
    end
  end
  
  def load_has_capacity_from_file!
    File.open(File.join("#{@db_path}/#{@db_name}", "has_capacity.json"), "r") do |f|
      @has_capacity = JSON.parse(f.read).as_bool
    end
  end
  
  def load_everything_from_files!
    load_from_files!
    load_last_entry_from_file!
    load_max_partition_archive_id_from_file!
    load_partition_archive_id_from_file!
    load_max_capacity_from_file!
    load_has_capacity_from_file!
    load_db_name_with_no_archive_from_file!
    load_partition_addition_amount_from_file!
    load_endless_add_from_file!
  end
  
  def save_db_name_with_no_archive_to_file!
    File.open(File.join(@db_path, "db_name_with_no_archive.json"), "w") do |f|
      f.write(@original_db_name.to_json)
    end
  end
  
  def load_db_name_with_no_archive_from_file!
    File.open(File.join(@db_path, "db_name_with_no_archive.json"), "r") do |f|
      @original_db_name = JSON.parse(f.read).as_s
    end
  end
  
  def save_endless_add_to_file!
    File.open(File.join("#{@db_path}/#{@db_name}", "endless_add.json"), "w") do |f|
      f.write(@endless_add.to_json)
    end
  end
  
  def load_endless_add_from_file!
    File.open(File.join("#{@db_path}/#{@db_name}", "endless_add.json"), "r") do |f|
      @endless_add = JSON.parse(f.read).as_bool
    end
  end
  
  def save_partition_addition_amount_to_file!
    File.open(File.join("#{@db_path}/#{@db_name}", "partition_addition_amount.json"), "w") do |file|
      file.write(@partition_addition_amount.to_json)
    end
  end
  
  def load_partition_addition_amount_from_file!
    File.open(File.join("#{@db_path}/#{@db_name}", "partition_addition_amount.json"), "r") do |file|
      @partition_addition_amount = JSON.parse(file.read).as_i
    end
  end
end