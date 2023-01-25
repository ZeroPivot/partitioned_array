require 'fileutils'
require 'json'
# PartitionedArray class, a data structure that is partitioned at a lower level, but functions as an almost-normal array at the high level
class PartitionedArray
  attr_accessor :range_arr, :rel_arr, :db_size, :data_arr, :partition_amount_and_offset, :db_path, :db_name, :partition_addition_amount
  PARTITION_AMOUNT = 3 # The initial, + 1
  OFFSET = 1 # This came with the math, but you can just state the PARTITION_AMOUNT in total and not worry about the offset in the end
  DB_SIZE = 10 # Caveat: The DB_SIZE is the total # of partitions, but you subtract it by one since the first partition is 0, in code.
  DEFAULT_PATH = './CGMFS' # default fallSback/write to current path
  DEBUGGING = false
  PAUSE_DEBUG = false
  DB_NAME = 'partitioned_array_slice'
  PARTITION_ADDITION_AMOUNT = 1 # The amount of partitions to add when the array is full
  DYNAMICALLY_ALLOCATES = true # If true, the array will dynamically allocate more partitions when it is full
  LABEL_INTEGER = false
  LABEL_RANGES = false
  def initialize(label_integer: LABEL_INTEGER, label_ranges: LABEL_RANGES, partition_addition_amount: PARTITION_ADDITION_AMOUNT, dynamically_allocates: DYNAMICALLY_ALLOCATES, db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: DEFAULT_PATH, db_name: DB_NAME)
    @label_integer = label_integer
    @label_ranges = label_ranges
    @db_size = db_size
    @partition_amount_and_offset = partition_amount_and_offset
    @allocated = false
    @db_path = db_path
    @data_arr = [] # the data array which contains the data, has to be partitioned accordingly
    @range_arr = [] # the range array which maintains the partition locations
    @rel_arr = [] # a basic array from 1..n used in binary search
    @db_name = db_name

    @partition_addition_amount = partition_addition_amount
    @dynamically_allocates = dynamically_allocates
  end
  def [](*ids, hash: false, label_ranges: @label_ranges, label_integer: @label_integer)
    #puts "ids: #{ids[0]}"
    return get(ids[0], hash: hash) if (ids.size==1 && ids[0].is_a?(Integer) && !label_integer)
    return { ids[0] => get(ids[0], hash: hash) } if ids.size==1 && ids[0].is_a?(Integer) && label_integer
    #return get(id, hash: hash) if id.is_a? Integer
    ids.map do |id|
      case id
      when Integer
        if (label_integer)
          { id => get(id, hash: hash) } if label_integer
        else
          get(id, hash: hash) if !label_integer
        end
        
      when Range
        if (label_ranges)
          id.to_a.map { |i| { i => get(i, hash: hash) }} if label_ranges
        else
          id.to_a.map { |i| get(i, hash: hash) } if !label_ranges
        end
      else
        raise "Invalid id type: #{id.class}"
      end  
    
    end
    #return id.to_a.map { |i| { i => get(i, hash: hash)} } if id.is_a? Range
  end
  def range_db_get(range_arr, db_num)
    range_arr[db_num]
  end

  def debug(string)
    p string if DEBUGGING
  end

  def delete(id)
    deleted = false
    if id <= (@data_arr.size - 1)
      @data_arr[id] = nil
      deleted = true
    end
    deleted
  end

  def load_dynamically_allocates_from_file!
    File.open(@db_path + '/' + 'dynamically_allocates.json', 'r') do |file|
      @dynamically_allocates = JSON.parse(file.read)
    end
  end

  def save_dynamically_allocates_to_file!
    #puts "in PA: @dynamically_allocates = #{@dynamically_allocates}" 
    FileUtils.touch(@db_path + '/' + 'dynamically_allocates.json')
    File.open(@db_path + '/' + 'dynamically_allocates.json', 'w') do |file|
      file.write(@dynamically_allocates.to_json)
    end
  end

  def delete_partition_subelement(id, partition_id)
    # delete the partition's array element to what is specified
    @data_arr[@range_arr[partition_id].to_a[id]] = nil
  end

  def set_partition_subelement(id, partition_id, &block)
    set_successfully = false
    # set the partition's array element to what is specified
    partition = get_partition(partition_id)
    if id <= (@data_arr.size - 1) && partition
      if block_given? && partition[id].instance_of?(Hash)
        block.call(partition[id])
        set_successfully = true
      elsif (id <= @data_arr.size - 1) && partition[id].nil? && block_given?
        @data_arr[@range_arr[partition_id].to_a[id]] = {}
        debug "d_arr: #{@data_arr[@range_arr[partition_id].to_a[id]]}"
        block.call(@data_arr[@range_arr[partition_id].to_a[id]])
        set_successfully = true
      end
    end
    set_successfully
  end

  def delete_partition(partition_id)
    # delete the partition id data
    debug "Partition ID: #{partition_id}"
    @data_arr[@range_arr[partition_id]].each_with_index do |_, index|
      @data_arr[index] = nil
    end
  end

  def get_partition(partition_id)
    # get the partition id data
    debug "Partition ID: #{partition_id}"
    if partition_id <= @db_size - 1
      @data_arr[@range_arr[partition_id]]
    else
      debug("SliceID #{partition_id} is out of bounds.")
      nil
    end
  end

  def set(id, &block)
    if id <= @db_size - 1
      if block_given? && @data_arr[id].instance_of?(Hash)
        block.call(@data_arr[id]) # put the openstruct into the block as an argument
        # @data_arr[id] = data
        debug "block given"
      elsif block_given? && @data_arr[id].nil?
        # this element in particular must have been turned off; every initial element is an OpenStruct and nil if that partition was deactivated
        debug "Loading array element #{id} from nil"
        @data_arr[id] = {}
        block.call(@data_arr[id])
      else
        raise "No block given for element #{id}"
      end
    end
  end

  def add(return_added_element_id: true, &block) 
    element_id_to_return = nil
    @data_arr.each_with_index do |element, element_index|
      #puts "element: #{element}"
      if element == {} && block_given? # (if element is nill, no data is added because the partition is "offline")
        block.call(@data_arr[element_index]) # seems == to block.call(element)
        if @dynamically_allocates && (element_index == @db_size - 1 && at_capacity?)
          @partition_addition_amount.times { add_partition } #if element_index == @data_arr.size - 1 # easier code; add if you reach the end of the array
          save_all_to_files! # save the data to the files
        end
        element_id_to_return = element_index
        break
      elsif !block_given?
        raise "No block given for element #{element}"
      end
    end
    return element_id_to_return if return_added_element_id
  end

  def allocate(db_size: @db_size, partition_amount_and_offset: @partition_amount_and_offset, override: false)
    if !@allocated || override
      @allocated = false
      partition = 0

      db_size.times do
        if @range_arr.empty?
          partition += partition_amount_and_offset
          @range_arr << (0..partition)
          next
        end
        partition += partition_amount_and_offset
        @range_arr << ((partition - partition_amount_and_offset + 1)..partition)
        debug_and_pause "@range_arr: #{@range_arr}"
      end

      x = 0 # offset test, for debug purposes
      @data_arr = (0..(db_size * (partition_amount_and_offset - x))).to_a.map { {} } # for an array that fills to less than the max of @rel_arr
      @rel_arr = @data_arr.size.times.map { |i| i } # for an array that fills to less than the max of @rel_arr
      @allocated = true
    else
      debug 'Initial database has been already allocated.'
    end
    debug "@data_arr element count: #{@data_arr.flatten.count - 1}"
    debug "@data_arr: #{@data_arr}"

    @allocated = true
  end

  def get(id, hash: false)
    return nil unless @allocated # if the database has not been allocated, return nil
    data = nil
    db_index = nil
    relative_id = nil

    @range_arr.each_with_index do |range, index|
      relative_id = range.bsearch { |element| @rel_arr[element] >= id }
      if relative_id
        db_index = index
        if range_db_get(@range_arr, db_index).member? @rel_arr[relative_id]
          break
        end
      else
        db_index = nil
        relative_id = nil
      end
    end

    unless relative_id && db_index
      debug 'The value could not be found'
    else
      debug "db_index: #{db_index}"

      # Special case; composing the array_id
      if db_index.zero?
        array_id = relative_id - db_index * @partition_amount_and_offset
      else
        array_id = (relative_id - db_index * @partition_amount_and_offset) - 1
      end

      debug "The value was found at #{array_id} in the array (data_arr)"
      if hash
        data = { "data_partition" => @data_arr[@range_arr[db_index]], "db_index" => db_index, "array_id" => array_id, "data" => @data_arr[@range_arr[db_index].to_a[array_id]], "db_size" => @db_size }
      else
        data = @data_arr[@range_arr[db_index].to_a[array_id]]
      end
    end
    data
  end

  def add_partition
    last_range_num = @range_arr.last.to_a.last + 1
    debug "last_range_num: #{last_range_num}"
    @range_arr << (last_range_num..(last_range_num + @partition_amount_and_offset - 1)) #works

    (last_range_num..(last_range_num + @partition_amount_and_offset - 1)).to_a.each do |i|
      @data_arr << {}
      @rel_arr << i
    end

    @db_size += 1
    debug "Partition added successfully; data allocated"
    debug "@data_arr: #{@data_arr}"
  end

  def string2range(range_string)
    split_range = range_string.split("..")
    split_range[0].to_i..split_range[1].to_i
  end

  def debug_and_pause(message)
    puts message if PAUSE_DEBUG
    gets if PAUSE_DEBUG
  end

  def load_from_files!(db_folder: @db_folder)
    load_partition_addition_amount_from_file!
    load_dynamically_allocates_from_file!
    # @db_size needs to be taken into account and changed accordingly
    path = "#{@db_path}/#{@db_name}"    
    @partition_amount_and_offset = File.open("#{path}/partition_amount_and_offset.json", 'r') { |f| JSON.parse(f.read) }
    @range_arr = File.open("#{path}/range_arr.json", 'r') { |f| JSON.parse(f.read) }
    @range_arr.map!{ |range_element| string2range(range_element) }
    @rel_arr = File.open("#{path}/rel_arr.json", 'r') { |f| JSON.parse(f.read) }
    @db_size = File.open("#{path}/db_size.json", 'r') { |f| JSON.parse(f.read) }
    data_arr_set_partitions = []
    0.upto(@db_size - 1) do |partition_element_index|
      data_arr_set_partitions << File.open("#{path}/#{@db_name}_part_#{partition_element_index}.json", 'r') { |f| JSON.parse(f.read) }
      @data_arr = data_arr_set_partitions.flatten # side effect: if you don't flatten it, you get an array with partitioned array elements
    end
    @allocated = true
  end

  def all_empty_partitions?
    @data_arr.all?(&:nil?)
  end

  def dup_data_arr!
    @data_arr.clone
  end

  def load_partition_from_file!(partition_id)
    path = "#{@db_path}/#{@db_name}"
    # @data_arr = File.open("#{path}/data_arr.json", 'r') { |f| JSON.parse(f.read) } # can write the entire array to disk for certain operations
    @partition_amount_and_offset = File.open("#{path}/partition_amount_and_offset.json", 'r') { |f| JSON.parse(f.read) }
    @range_arr = File.open("#{path}/range_arr.json", 'r') { |f| JSON.parse(f.read) }
    @range_arr.map!{|range_element| string2range(range_element) }
    @rel_arr = File.open("#{path}/rel_arr.json", 'r') { |f| JSON.parse(f.read) }
    sliced_range_arr = @range_arr[partition_id].to_a.map { |range_element| range_element }
    partition_data = File.open("#{path}/#{@db_name}_part_#{partition_id}.json", 'r') { |f| JSON.parse(f.read) }
    ((sliced_range_arr[0].to_i)..(sliced_range_arr[-1].to_i)).to_a.each do |range_element|
      @data_arr[range_element] = partition_data[range_element]
    end
    @data_arr[@range_arr[partition_id]]
  end

  def save_partition_to_file!(partition_id, db_folder: @db_folder)
    partition_data = get_partition(partition_id)
    path = "#{@db_path}/#{@db_name}"
    File.open("#{path}/#{db_folder}/#{@db_name}_part_#{partition_id}.json", 'w') { |f| f.write(partition_data.to_json) }
  end

  def save_partition_addition_amount_to_file!(db_folder: @db_folder)
    path = "#{@db_path}/#{@db_name}"
    FileUtils.touch("#{path}/#{db_folder}/partition_addition_amount.json")
    File.open("#{path}/#{db_folder}/partition_addition_amount.json", 'w') { |f| f.write(@partition_amount_and_offset.to_json) }
  end

  def load_partition_addition_amount_from_file!(db_folder: @db_folder)
    path = "#{@db_path}/#{@db_name}"
    @partition_addition_amount = File.open("#{path}/#{db_folder}/partition_addition_amount.json", 'r') { |f| JSON.parse(f.read) }
  end

  def save_all_to_files!(db_folder: @db_folder, db_path: @db_path, db_name: @db_name)
    
    unless Dir.exist?(db_path)
      Dir.mkdir(db_path)
    end
    path = "#{db_path}/#{db_name}"

    unless Dir.exist?(path)
      Dir.mkdir(path)
    end

    save_partition_addition_amount_to_file!
    save_dynamically_allocates_to_file!
    File.open("#{path}/#{db_folder}/partition_amount_and_offset.json", 'w'){|f| f.write(@partition_amount_and_offset.to_json) }
    File.open("#{path}/#{db_folder}/range_arr.json", 'w'){|f| f.write(@range_arr.to_json) }
    File.open("#{path}/#{db_folder}/rel_arr.json", 'w'){|f| f.write(@rel_arr.to_json) }
    File.open("#{path}/#{db_folder}/db_size.json", 'w'){|f| f.write(@db_size.to_json) }
    debug path
    0.upto(@db_size-1) do |index|
      FileUtils.touch("#{path}/#{db_folder}/#{@db_name}_part_#{index}.json")
      File.open("#{path}/#{@db_name}_part_#{index}.json", 'w') do |f|
        partition = get_partition(index)
        debug_and_pause("partition index: #{index}")
        debug "partition index: #{index}"
        debug "@db_size: #{@db_size}"
        debug "partition: #{partition}"
        debug "@rel_arr: #{@rel_arr}"
        debug "@range_arr: #{@range_arr}"
        debug "@data_arr: #{@data_arr.size}"
        debug "@data_arr: #{@data_arr}"
        f.write(partition.to_json)
      end
    end
  end
end