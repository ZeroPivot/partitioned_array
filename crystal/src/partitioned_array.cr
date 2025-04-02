require "json"
require "file_utils"

class PartitionedArray
  property data_arr : Array(Hash(String, JSON::Any)?)
  property db_size : Int32
  property partition_amount_and_offset : Int32
  property db_path : String
  property db_name : String
  property dynamically_allocates : Bool
  property label_integer : Bool
  property label_ranges : Bool
  property partition_addition_amount : Int32
  
  # Constants
  PARTITION_AMOUNT = 9
  OFFSET = 1
  DB_SIZE = 20
  DEFAULT_PATH = "./DB_TEST"
  DYNAMICALLY_ALLOCATES = true
  PARTITION_ADDITION_AMOUNT = 1
  LABEL_INTEGER = false
  LABEL_RANGES = false
  
  def initialize(
    @label_integer = LABEL_INTEGER,
    @label_ranges = LABEL_RANGES,
    @partition_addition_amount = PARTITION_ADDITION_AMOUNT,
    @dynamically_allocates = DYNAMICALLY_ALLOCATES,
    @db_size = DB_SIZE,
    @partition_amount_and_offset = PARTITION_AMOUNT + OFFSET,
    @db_path = DEFAULT_PATH,
    @db_name = "partitioned_array"
  )
    @data_arr = Array(Hash(String, JSON::Any)?).new(@db_size) { nil }
  end
  
  def allocate
    @data_arr.each_with_index do |_, i|
      next if i >= @db_size
      @data_arr[i] = {} of String => JSON::Any if @data_arr[i].nil?
    end
  end
  
  def get(id : Int32, hash = false)
    return nil if id.nil?
    
    arr_pos = get_arr_pos(id)
    pos_in_arr = get_pos_in_arr(id)
    
    return nil if arr_pos >= @data_arr.size || @data_arr[arr_pos].nil?
    
    if hash
      {"value" => @data_arr[arr_pos][pos_in_arr.to_s]?, "db_index" => arr_pos}
    else
      @data_arr[arr_pos][pos_in_arr.to_s]?
    end
  end
  
  def set(id : Int32)
    arr_pos = get_arr_pos(id)
    pos_in_arr = get_pos_in_arr(id)
    
    if arr_pos >= @data_arr.size
      if @dynamically_allocates
        add_partition(arr_pos - @data_arr.size + 1)
      else
        return nil
      end
    end
    
    @data_arr[arr_pos] = {} of String => JSON::Any if @data_arr[arr_pos].nil?
    
    if block_given?
      yield @data_arr[arr_pos]
    end
    
    @data_arr[arr_pos][pos_in_arr.to_s]
  end
  
  def add_partition(amount = 1)
    amount.times do
      @data_arr << {} of String => JSON::Any
    end
  end
  
  def get_arr_pos(id : Int32) : Int32
    id / @partition_amount_and_offset
  end
  
  def get_pos_in_arr(id : Int32) : Int32
    id % @partition_amount_and_offset
  end
  
  def save_all_to_files!
    FileUtils.mkdir_p(File.join(@db_path, @db_name))
    
    @data_arr.each_with_index do |partition, i|
      next if partition.nil?
      save_partition_to_file!(i)
    end
  end
  
  def save_partition_to_file!(partition_id : Int32)
    return if @data_arr[partition_id].nil?
    
    dir_path = File.join(@db_path, @db_name)
    FileUtils.mkdir_p(dir_path)
    
    File.open(File.join(dir_path, "#{partition_id}.json"), "w") do |f|
      f.write(@data_arr[partition_id].to_json)
    end
  end
  
  def load_from_files!
    dir_path = File.join(@db_path, @db_name)
    return unless Dir.exists?(dir_path)
    
    Dir.entries(dir_path).each do |file|
      next unless file.ends_with?(".json")
      partition_id = file.gsub(".json", "").to_i
      load_partition_from_file!(partition_id)
    end
  end
  
  def load_partition_from_file!(partition_id : Int32)
    file_path = File.join(@db_path, @db_name, "#{partition_id}.json")
    return unless File.exists?(file_path)
    
    json_str = File.read(file_path)
    @data_arr[partition_id] = Hash(String, JSON::Any).from_json(json_str)
  end
  
  def add(return_added_element_id = true)
    latest_id = find_latest_id
    latest_id += 1
    
    arr_pos = get_arr_pos(latest_id)
    
    if arr_pos >= @data_arr.size && @dynamically_allocates
      add_partition((arr_pos - @data_arr.size) + @partition_addition_amount)
    end
    
    if block_given?
      set(latest_id) { |entry| yield entry }
    else
      set(latest_id)
    end
    
    return_added_element_id ? latest_id : nil
  end
  
  def find_latest_id
    latest_id = -1
    
    @data_arr.each_with_index do |partition, arr_pos|
      next if partition.nil?
      
      partition.keys.each do |key|
        id = (arr_pos * @partition_amount_and_offset) + key.to_i
        latest_id = id if id > latest_id
      end
    end
    
    latest_id
  end
end