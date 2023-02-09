require 'fileutils'
require 'json'
# PartitionedArray class, a data structure that is partitioned at a lower level, but functions as an almost-normal array at the high level
class PartitionedArray
  # Access individual instance variables with caution...
  attr_accessor :range_arr, :rel_arr, :db_size, :data_arr, :partition_amount_and_offset, :db_path, :db_name, :partition_addition_amount

  # DB_SIZE > PARTITION_AMOUNT
  PARTITION_AMOUNT = 3 # The initial, + 1
  OFFSET = 1 # This came with the math, but you can just state the PARTITION_AMOUNT in total and not worry about the offset in the end
  DB_SIZE = 10 # Caveat: The DB_SIZE is the total # of partitions, but you subtract it by one since the first partition is 0, in code.
  DEFAULT_PATH = './CGMFS' # default fallSback/write to current path
  DEBUGGING = false
  PAUSE_DEBUG = false
  DB_NAME = 'partitioned_array_slice'
  PARTITION_ADDITION_AMOUNT = 1 # The amount of partitions to add when the array is full
  DYNAMICALLY_ALLOCATES = true # If true, the array will dynamically allocate more partitions when it is full
  
  # for []
  LABEL_INTEGER = false
  LABEL_RANGES = false

  def initialize(label_integer: LABEL_INTEGER, label_ranges: LABEL_RANGES, partition_addition_amount: PARTITION_ADDITION_AMOUNT, dynamically_allocates: DYNAMICALLY_ALLOCATES, db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: DEFAULT_PATH, db_name: DB_NAME)
=begin
# Here is the explanation for the code below:
1. Partition addition amount: the amount of partitions that will be added once the database reaches its limit. For example, if the partition addition amount is 10, then the database will add 10 new partitions to the database once it reaches its limit.
2. Dynamically allocates: if the database is not full, then the database will not dynamically allocate new partitions. This is to prevent the database from creating too many partitions.
3. DB size: the size of the database. If the database reaches its limit, then the database will start to dynamically allocate new partitions.
4. Partition amount and offset: the amount of partitions and offset. For example, if the offset is 10 and the partition amount is 3, then the database will have 3 partitions, which are 10, 20, and 30.
5. DB path: the path of the database.
6. DB name: the name of the database.
7. Data array: the array that contains the data.
8. Range array: the array that contains the partitions.
9. Rel array: the array that contains the partition locations.
10. DB name: the name of the database. #
=end
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
### LABEL_INTEGER LABEL_RANGES end here

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
  # set the partition's array element to what is specified

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

  # TODO: Class#set(integer id) -> boolean
  # Will yield a hash to some element id within the data array, to which you could use a block and modify said data
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

  # We define the add_left routine as starting from the end of @data_arr, and working the way back
  # until we find the first element that is nilm if no elements return nil, then return nil as well
  def add(return_added_element_id: true, &block) 
    # figure out what to have add return, but for now its technically in a programming sense "void", because this
    # function always works, so long as you have a block
    # Proposal: have add return the id of the element that was added, and have the caller know if it was added successfully
    # What's currently implemented: since its pointless to check for truthiness, we set everything up to generally only return the added element id
    # Why? This could become useful as a shortcut in game development, where you can just use the id to reference the element in the array
    # and you use the block to modify the element if you want to

    # add the data to the array, searching until an empty hash elemet is found
    
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

  # create an initial database (instance variable)
  # later on, make this so it will load a database if its there, and if there's no data, create a standard database then save it
  # Set to work with the default constants
  def allocate(db_size: @db_size, partition_amount_and_offset: @partition_amount_and_offset, override: false)
    if !@allocated || override
      @allocated = false
      partition = 0

      # TODO: @range_arr does not create a range index correctly and numbers may overlap
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

  # Returns a hash based on the array element you are searching for.
  # Haven't done much research afterwards on the idea of
  # whether the binary search is necessary, but it seems like it is.
  # The idea first came up during the research of the partitioned array equation.
  def get(id, hash: false)
    return nil unless @allocated # if the database has not been allocated, return nil
    #return nil if id.nil? # if the id is nil, return nil. This is a safety check.

    ### Commented this code out on 2022-08-11 in light of fixing add_partition
    # return @data_arr.first if id.zero?
    # return @data_arr.last if id == @data_arr.count - 1
    # If you do this, you will not be able to request a hash in these cases

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
    # NOTE: add_partition is not working properly, and has to look at PARTITION_ADDITION_AMOUNT to determine how many partitions to add. Keep this in mind when debugging.
    # add a partition to the @range_arr, add partition_amount_and_offset to @rel_arr, @db_size increases by one
    # debug_and_pause("add_partition called")
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

  # loads the files within the directory CGMFS/partitioned_array_slice
  # needed things
  # range_arr => it is the array of ranges that the database is divided into
  # data_arr => it is output to json
  # rel_arr => it is output to json
  # part_} => it is taken from the range_arr subdivisions; perform a map and load it into the database, one by one
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


# Plan: be able to dump @data_arr to disk anytime you want
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
    # Bug: files are not being written correctly.
    # Fix: (8/11/2022 - 5:55am) - add db_size.json
    
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

require_relative 'partitioned_array'
# NOTE: ManagedPartitionedArray and PartitionedArray have different versions. PartitionedArray can work along but
# ManagedPartitionedArray, while being the superset, depends on PartitionedArray
# VERSION v2.1.1-mpa-release - LABEL_INTEGER - LABEL_RANGES and many bug fixes in initialize
# Known bugs/issues:
# initialize_max_partition_archive_id! - creates a directory on start, albeit this is the basis directory
# may not be a need to complicate things though. At some point in time, address it, but initially it only writes a folder and a single file into it on start
# VERSION v2.1.0-mpa-release - First release
## Implemented
# def strip_archived_db_name(db_name: @original_db_name)    
#  #return db_name.sub(/\[.+\]/, '')
#  # from dragonruby implementation; doesn't use regular expressions
#  return db_name.split('[')[0]    
# end
# def [](id, hash:false) -- added in PartitionedArray (lib/partitioned_array.rb)
## Switched from regular expression usage to splitting the db_name string, should be a tinge bit faster
# VERSION v2.0.0-mpa / v1.2.6-pa - added more arguments to the archive! methods, since file partition contexts don't need to exactly meet with all the others
# VERSION v1.3.2-mpa / v1.2.5a-pa - save and load partition from disk now auto-saves all variables, since those always change often (10/21/2022 1:11PM)
# VERSION ManagedPartitionedArray/PartitionedArray - v1.3.1release(MPA)/v1.2.5a(PA) (MPA-v1.3.1-rel_PA-v1.2.5a-rel)
# - cleanup and release new version (10/19/2022 - 1:50PM)

# VERSION v1.3.0a - endless add implementation in ManagedPartitionedArray#endless_add
# Allows the database to continuously add and allocate, as if it were a plain PartitionedArray
# NOTE: consider the idea that adding a partition may mean that it saves all variables and everything to disk
# SUGGESTION: working this out by only saving by partition, and not by the whole database
# SUGGESTION: this would mean that the database would have to be loaded from the beginning, but that's not a big deal
# VERSION v1.2.9 - fixes
# VERSION v1.2.8 - Regression and bug found and fixed; too many guard clauses at at_capacity? method (10/1/2022)
# VERSION v1.2.7 - fixed more bugs with dynamic allocation
# VERSION v1.2.6 - bug fix with array allocation given that you don't want to create file partitions (9/27/2022 - 7:09AM)
# VERSION v1.2.5 - bug fixes
# VERSION: v1.1.4 - seemed to have sorted out the file issues... but still need to test it out
# VERSION: v1.1.3 
# many bug fixes; variables are now in sync with file i/o
# Stopped: problem with @latest_id not being set correctly
# working on load_from_archive! and how it will get the latest archive database and load up all the variables, only it seems
# that there is something wrong with that. 
# VERSION: v1.1.2 (9/13/2022 10:17 am)
# Prettified
# Added raise to ManagedPartitionedArray#at_capacity? if @has_capacity == false
# VERSION: v1.1.1a - got rid of class variables, and things seem to be fully working now
# VERSION: v1.1.0a - fully functional, but not yet tested--test in the real world
# VERSION: v1.0.2 - more bug fixes, added a few more tests
# VERSION: v1.0.1 - bug fixes
# VERSION: v1.0.0a - fully functional at a basic level; can load archives and the max id of the archive is always available
# VERSION: v0.1.3 - file saving and other methods properly working
# VERSION: v0.1.2 - added managed databases, but need to add more logic to make it work fully
# VERSION: v0.1.1
# UPDATE 8/31/2022: @latest_id increments correctly now
# Manages the @last_entry variable, which tracks where the latest entry is, since PartitionedArray is dynamically allocated.
class ManagedPartitionedArray < PartitionedArray 
  attr_accessor :endless_add, :range_arr, :rel_arr, :db_size, :data_arr, :partition_amount_and_offset, :db_path, :db_name, :max_capacity, :has_capacity, :latest_id, :partition_archive_id, :max_partition_archive_id, :db_name_with_no_archive

  # DB_SIZE > PARTITION_AMOUNT
  PARTITION_AMOUNT = 9 # The initial, + 1
  OFFSET = 1 # This came with the math, but you can just state the PARTITION_AMOUNT in total and not worry about the offset in the end
  DB_SIZE = 20 # Caveat: The DB_SIZE is the total # of partitions, but you subtract it by one since the first partition is 0, in code. that is, it is from 0 to DB_SIZE-1, but DB_SIZE is then the max allocated DB size
  PARTITION_ARCHIVE_ID = 0
  DEFAULT_PATH = "./DB_TEST" # default fallback/write to current path
  DEBUGGING = false
  PAUSE_DEBUG = false
  DB_NAME = 'partitioned_array_slice'
  PARTITION_ADDITION_AMOUNT = 1
  MAX_CAPACITY = "data_arr_size" # : :data_arr_size; a keyword to add to the array until its full with no buffer additions
  HAS_CAPACITY = true # if false, then the max_capacity is ignored and at_capacity? raises if @has_capacity == false
  DYNAMICALLY_ALLOCATES = true
  ENDLESS_ADD = false

  LABEL_INTEGER = false
  LABEL_RANGES = false

  def initialize(label_integer: LABEL_INTEGER, label_ranges: LABEL_RANGES, endless_add: ENDLESS_ADD, dynamically_allocates: DYNAMICALLY_ALLOCATES, partition_addition_amount: PARTITION_ADDITION_AMOUNT, max_capacity: MAX_CAPACITY, has_capacity: HAS_CAPACITY, partition_archive_id: PARTITION_ARCHIVE_ID, db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: DEFAULT_PATH, db_name: DB_NAME) 
    @db_path = db_path
    @db_size = db_size
    @db_name = db_name
    @partition_amount_and_offset = partition_amount_and_offset
    @partition_archive_id = partition_archive_id
    @original_db_name = strip_archived_db_name(db_name: @db_name)
    @db_name_with_archive = db_name_with_archive(db_name: @original_db_name, partition_archive_id: @partition_archive_id)    
    @max_capacity = max_capacity
    @latest_id = 0 # last entry    
    # @max_capacity = max_capacity_setup! # => commented out on 10/4/2022 1:32am
    @has_capacity = has_capacity
    @max_partition_archive_id = initialize_max_partition_archive_id!
    @partition_addition_amount = partition_addition_amount
    @max_capacity = max_capacity_setup!
    @dynamically_allocates = dynamically_allocates  
    @endless_add = endless_add # add endlessly like a regular partitioned array
    @label_integer = label_integer
    @label_ranges = label_ranges
    super(label_integer: @label_integer, label_ranges: @label_ranges, partition_addition_amount: @partition_addition_amount, dynamically_allocates: @dynamically_allocates, db_size: @db_size, partition_amount_and_offset: @partition_amount_and_offset, db_path: @db_path, db_name: @db_name_with_archive)
  end

  # one keyword available: :data_arr_size
  def max_capacity_setup!
    #p "@max_capacity: #{@max_capacity}"#{@max_capacity} if DEBUGGING"
    if (@max_capacity == "data_arr_size")
      #@max_capacity = (0..(db_size * (partition_amount_and_offset))).to_a.size - 1
      #@partition_addition_amount = partition_addition_amount
      return "data_arr_size"
    else
      return max_capacity
    end
  end

  def save_data_arr_to_disk!
    # WIP
  end

  def dump_all_variables
    p "db_size: #{@db_size}"
    p "partition_amount_and_offset: #{@partition_amount_and_offset}"
    p "db_path: #{@db_path}"
    p "db_name: #{@db_name}"
    p "max_capacity: #{@max_capacity}"
    p "has_capacity: #{@has_capacity}"
    p "latest_id: #{@latest_id}"
    p "partition_archive_id: #{@partition_archive_id}"  
    p "db_name_with_no_archive: #{@db_name_with_no_archive}"
    p "db_name_with_archive: #{@db_name_with_archive}"
    p "max_partition_archive_id: #{@max_partition_archive_id}"
    p "partition_addition_amount: #{@partition_addition_amount}"
    p "dynamically_allocates: #{@dynamically_allocates}"
    p "endless_add: #{@endless_add}"
  end

  def archive_and_new_db!(label_integer: @label_integer, label_ranges: @label_ranges, auto_allocate: true, partition_addition_amount: @partition_addition_amount, max_capacity: @max_capacity, has_capacity: @has_capacity, partition_archive_id: @partition_archive_id, db_size: @db_size, partition_amount_and_offset: @partition_amount_and_offset, db_path: @db_path, db_name: @db_name_with_archive)
    save_everything_to_files!
    @partition_archive_id += 1
    increment_max_partition_archive_id!
    temp = ManagedPartitionedArray.new(label_integer: label_integer, label_ranges: label_ranges, max_capacity: @max_capacity, partition_archive_id: @partition_archive_id, db_size: @db_size, partition_amount_and_offset: @partition_amount_and_offset, db_path: @db_path, db_name: @db_name_with_archive)
    temp.allocate if auto_allocate
    return temp
  end

  ## ex ManagedPartitionedArray#load_archive_no_auto_allocate!(partition_archive_id: partition_archive_id, ...)
  def load_archive_no_auto_allocate!(label_integer: @label_integer, label_ranges: @label_ranges, has_capacity: @has_capacity, dynamically_allocates: @dynamically_allocates, endless_add: @endless_add, partition_archive_id: @max_partition_archive_id, db_size: @db_size, partition_amount_and_offset: @partition_amount_and_offset, db_path: @db_path, db_name: @db_name_with_archive, max_capacity: @max_capacity, partition_addition_amount: @partition_addition_amount)
    temp = ManagedPartitionedArray.new(label_integer: label_integer, label_ranges: label_ranges, dynamically_allocates: dynamically_allocates, endless_add: endless_add, max_capacity: max_capacity, partition_archive_id: partition_archive_id, db_size: db_size, partition_amount_and_offset: partition_amount_and_offset, db_path: db_path, db_name: db_name_with_archive)
    return temp
  end

  # ex ManagedPartitionedArray#load_from_archive!(partition_archive_id: partition_archive_id, ...)
  def load_from_archive!(label_integer: @label_integer, label_ranges: @label_ranges, has_capacity: @has_capacity, dynamically_allocates: @dynamically_allocates, endless_add: @endless_add, partition_archive_id: @max_partition_archive_id, db_size: @db_size, partition_amount_and_offset: @partition_amount_and_offset, db_path: @db_path, db_name: @db_name_with_archive, max_capacity: @max_capacity, partition_addition_amount: @partition_addition_amount)
    temp = ManagedPartitionedArray.new(label_integer: label_integer, label_ranges: label_ranges, dynamically_allocates: dynamically_allocates, endless_add: endless_add, max_capacity: max_capacity, partition_archive_id: partition_archive_id, db_size: db_size, partition_amount_and_offset: partition_amount_and_offset, db_path: db_path, db_name: db_name_with_archive)
    temp.load_everything_from_files!
    return temp
  end

#### lagel_integer and label_ranges v2.1.1 changes end here

  # ManagedPartitionedArray#at_capacity? checks to see if the partitioned array is at its capacity. It is imperative to use this when going through an iterator.
  def at_capacity?
    return false if @has_capacity == false
    case @max_capacity
      when "data_arr_size"
        if @latest_id >= @data_arr.size
          return true
        end
      when Integer
        if ((@latest_id >= @max_capacity) && @has_capacity)
          return true
        end
      else
        return false      
    end
  end

  def add(return_added_element_id: true, &block)
    # endless add addition here
    if @endless_add && @data_arr[@latest_id].nil?
      add_partition
      save_everything_to_files!
    elsif at_capacity?# && @max_capacity && @has_capacity #guards against adding any additional entries
      return false
    else 
      # PASS, additional code later is a possibility, but this code all takes place before super(), anyways
    end
    @latest_id += 1
    super(return_added_element_id: return_added_element_id, &block)
  end

  def load_everything_from_files!
    load_from_files! #PartitionedArray#load_from_files!
    load_last_entry_from_file!
    load_max_partition_archive_id_from_file!
    load_partition_archive_id_from_file!
    load_max_capacity_from_file!
    load_has_capacity_from_file!
    load_db_name_with_no_archive_from_file!
    load_partition_addition_amount_from_file!
    load_endless_add_from_file!
  end

  def load_partition_from_file!(partition_id, load_variables: true)
    load_variables_from_disk! if load_variables
    super(partition_id)
  end

  # save_variables: added 10/21/2022; all variables saved/loaded to disk by default, to work around an issue where I didn't realize I needed to save variables
  def save_partition_to_file!(partition_id, save_variables: true)
    save_variables_to_disk! if save_variables
    super(partition_id)
  end


  def save_everything_to_files!
    save_all_to_files! #PartitionedArray#save_all_to_files!
    save_last_entry_to_file!
    save_partition_archive_id_to_file!
    save_max_partition_archive_id_to_file!
    save_max_capacity_to_file!
    save_has_capacity_to_file!
    save_db_name_with_no_archive_to_file!
    save_partition_addition_amount_to_file!
    save_endless_add_to_file!
  end

  def save_variables_to_disk!
    # Synchronize all known variables with their disk counterparts
    save_last_entry_to_file!
    save_partition_archive_id_to_file!
    save_max_partition_archive_id_to_file!
    save_max_capacity_to_file!
    save_has_capacity_to_file!
    save_db_name_with_no_archive_to_file!
    save_partition_addition_amount_to_file!
    save_endless_add_to_file!
  end

  def load_variables_from_disk!
    # Synchronize all known variables with their disk counterparts
    load_last_entry_from_file! 
    load_partition_archive_id_from_file!
    load_max_partition_archive_id_from_file!
    load_max_capacity_from_file!
    load_has_capacity_from_file!
    load_db_name_with_no_archive_from_file!
    load_partition_addition_amount_from_file!
    load_endless_add_from_file!
  end

  def increment_max_partition_archive_id!
    @max_partition_archive_id += 1
    File.open(@db_path + '/' + "max_partition_archive_id.json", "w") do |f|
      f.write(@max_partition_archive_id)
    end
  end

  def save_db_name_with_no_archive_to_file!
    File.open(File.join("#{@db_path}", "db_name_with_no_archive.json"), "w") do |f|
      f.write(@original_db_name.to_json)
    end
  end

  def load_db_name_with_no_archive_from_file!
    File.open(File.join("#{@db_path}", "db_name_with_no_archive.json"), "r") do |f|
      @original_db_name = JSON.parse(f.read)
    end
  end

  def save_has_capacity_to_file!
    File.open(File.join("#{@db_path}/#{@db_name}", "has_capacity.json"), "w") do |f|
      f.write(@has_capacity.to_json)
    end
  end

  def save_endless_add_to_file!
    File.open(File.join("#{@db_path}/#{@db_name}", "endless_add.json"), "w") do |f|
      f.write(@endless_add.to_json)
    end
  end

  def load_endless_add_from_file!
    File.open(File.join("#{@db_path}/#{@db_name}", "endless_add.json"), "r") do |f|
      @endless_add = JSON.parse(f.read)
    end
  end

  def load_has_capacity_from_file!
    File.open(File.join("#{@db_path}/#{@db_name}", "has_capacity.json"), "r") do |f|
      @has_capacity = JSON.parse(f.read)
    end
  end

  def save_last_entry_to_file!
    if @partition_archive_id == 0      
      File.open(File.join("#{@db_path}/#{db_name_with_archive(db_name: @original_db_name)}", 'last_entry.json'), 'w') do |file|
        file.write((@latest_id).to_json)
      end
    else      
      File.open(File.join("#{@db_path}/#{db_name_with_archive(db_name: @original_db_name)}", 'last_entry.json'), 'w') do |file|
        file.write((@latest_id).to_json)
      end
    end
  end

  def load_last_entry_from_file!
    File.open(File.join("#{@db_path}/#{db_name_with_archive(db_name: @original_db_name)}", 'last_entry.json'), 'r') do |file|
      @latest_id = JSON.parse(file.read)
    end
  end

  def save_partition_archive_id_to_file!
    File.open(File.join("#{@db_path}/#{db_name_with_archive(db_name: @original_db_name)}", 'partition_archive_id.json'), 'w') do |file|
      file.write(@partition_archive_id.to_json)
    end
  end

  def load_partition_archive_id_from_file!
    File.open(File.join("#{@db_path}/#{db_name_with_archive(db_name: @original_db_name)}", 'partition_archive_id.json'), 'r') do |file|
      @partition_archive_id = JSON.parse(file.read)
    end
  end

  def save_max_partition_archive_id_to_file!
    File.open(File.join(@db_path, 'max_partition_archive_id.json'), 'w') do |file|
      file.write(@max_partition_archive_id.to_json)
    end
  end

def initialize_max_partition_archive_id!
  # if the max_partition_archive_id.json file does not exist, create it and set it to 0
  if !File.exist?(File.join("#{@db_path}", "max_partition_archive_id.json"))
    FileUtils.mkdir_p(@db_path)
    File.open(File.join("#{@db_path}", "max_partition_archive_id.json"), "w") do |f|
      f.write(0)
    end
    @max_partition_archive_id = 0
  else
  # if the max_partition_archive_id.json file does exist, load it
  File.open(File.join("#{@db_path}", "max_partition_archive_id.json"), "r") do |f|
    @max_partition_archive_id = JSON.parse(f.read)
  end
  end
end


  def load_max_partition_archive_id_from_file!
    # puts "1 @db_path: #{@db_path}"
    if File.exist?(File.join(@db_path, 'max_partition_archive_id.json'))
      File.open(File.join(@db_path, 'max_partition_archive_id.json'), 'r') do |file|
        @max_partition_archive_id = JSON.parse(file.read)
      end
    else
      FileUtils.touch(File.join(@db_path, 'max_partition_archive_id.json'))
      File.open(File.join(@db_path, db_name_with_archive(db_name: @db_name, partition_archive_id: @partition_archive_id)), 'w') do |file|
        file.write(0)
      end      
      return 0
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

  

  def save_partition_addition_amount_to_file!
    File.open(File.join("#{@db_path}/#{@db_name}", 'partition_addition_amount.json'), 'w') do |file|
      file.write(@partition_addition_amount.to_json)
    end
  end

  def load_partition_addition_amount_from_file!
    File.open(File.join("#{@db_path}/#{@db_name}", 'partition_addition_amount.json'), 'r') do |file|
      @partition_addition_amount = JSON.parse(file.read)
    end
  end



  def db_name_with_archive(db_name: @original_db_name, partition_archive_id: @partition_archive_id)
    return "#{db_name}[#{partition_archive_id}]"
  end

  def strip_archived_db_name(db_name: @original_db_name)    
    #return db_name.sub(/\[.+\]/, '')
    # from dragonruby implementation; doesn't use regular expressions
    return db_name.split('[')[0]    
  end
end


require_relative 'file_context_managed_partitioned_array'
# VERSION v2.1.5-release - partition_addition_amount passes from partitioned_array_database to file_context_managed_partitioned_array_manager
# VERSION v2.1.4-release
## Implemented:
# def [](database_name = @active_database, database_table = @active_table)
#  database_table(database_table: database_table, database_name: database_name)
# end
## fixed redundant code, cleanup
#
# VERSION v2.1.3-release-candidate (rc1)
# FCMPAM#delete_database!(database_name) - deletes a database entry (untested)
# FCMPAM#delete_table!(database_table) - deletes a table entry (untested)
# TODO: possible: FCMPAM#delete_database_table_...!(database_name, database_table) - deletes a database table entry
# VERSION v2.1.2a 
# FCMPAM#new_database! - adds an entry to the database entries list and creates a database
# VERSION v2.1.1
# VERSION v2.1.0
# VERSION v2.0.7a
# VERSION v2.0.6a - add database (DATABASE_LIST_NAME) routines to store the set of databases that exist (1/12/2023 - 5:06AM)
# IN: FCMPAM#new_database!(database_name)
# VERSION v2.0.5 - release candidate (1/20/2023 - 4:26AM)
# VERSION v2.0.5a - tested FCMPAM#table_next_file_context!
# FCMPAM#table_set_file_context! untested, but is predictable
# VERSION v2.0.4a - untested, switch to normal version after successful test (1/9/2023 - 11:51PM)
# FCMPAM#table_set_file_context!(database_table: @active_table, database_name: @active_database, file_context_id: @db_partition_archive_id, save_prior: true, save_after: true)
# FCMPAM#table_next_file_context!(database_table: @active_table, database_name: @active_database, save_prior: true, save_after: true)
# VERSION v2.0.3a - add method structure skeleton (left off on line 247)
# PITFALLS: As it stands, MPA#archive_and_new_db! should not be called directly, as it is a value object. You could, however, allocate it to a variable that way, and then call it on that variable. 
# TODO: (1/3/2023 - 12:55PM)
# set a timestamp in the databases per transaction
# relational algebraic operations (cartesian product, etc.)
# VERSION v2.0.2a - add code (1/3/2023 1:48PM)
# VERSION v2.0.1a - prettify, remove old unused code; alias (1/3/2023 12:54PM)
# alias db_table database_table
# alias active_db active_database
# alias new_db! new_database! 
# VERSION v2.0.0a - Got the basics of the database table working, all works (1/3/2023)
# Defined Methods:
# FCMPAM#database(database_name = @active_database): returns the database object
# FCMPAM#database_table(database_name: @active_database, database_table: @active_table): returns the database table object
# FCMPAM#new_database!(database_name): creates a new database
# FCMPAM#new_table!(database_name:, database_table:): creates a new table in the database
# FCMPAM#active_database(database_name): sets the active database
# FCMPAM#active_table(database_table): sets the active table
# FCMPAM#table(database_table = @active_table): returns the active table
# FCMPAM#database(database_name = @active_database): returns the active database

# save_everything_to_files!: saves everything to files
# load_everything_from_files!: loads everything from files

# VERSION v1.0.3 - got man_db to contain the many tables of its own
# VERSION v1.0.2a - working on new_database, where the database table entries have to contain an array of the tables, so the database knows which tables belong to it
# VERSION v1.0.1a - -left off at line 169
# VERSION v0.1.0a - BASICS are working, in new_database_test (12/6/2022 - 8:14am)
# VERSION v0.0.6
# VERSION v0.0.5

# FileContextManagedPartitionedArrayManager - manages the FileContextManagedPartitionedArray and its partitions, making the Partitioned Array a database with database IDs
# and table keys
class FileContextManagedPartitionedArrayManager
  attr_accessor :man_db, :man_index, :fcmpa_db_indexer_db, :fcmpa_active_databases, :db_file_incrementor, :db_file_location, :db_path, :db_name, :db_size, :db_endless_add, :db_has_capacity, :fcmpa_db_indexer_name, :fcmpa_db_folder_name, :fcmpa_db_size, :fcmpa_partition_amount_and_offset, :db_partition_amount_and_offset, :partition_addition_amount, :db_dynamically_allocates, :timestamp_str

  INDEX = 0 # the index of the database in the database table, 0th element entry in any given database, primarily because the math leads to an extra entry in the first partition.

  # DB_SIZE > PARTITION_AMOUNT
  TRAVERSE_HASH = true
  FCMPA_PARTITION_AMOUNT = 9
  FCMPA_OFFSET = 1
  FCMPA_DB_ENDLESS_ADD = true
  FCMPA_DB_DYNAMICALLY_ALLOCATES = true
  FCMPA_DB_PARTITION_ADDITION_AMOUNT = 5
  FCMPA_DB_HAS_CAPACITY = true
  FCMPA_DB_MAX_CAPACITY = "data_arr_size"
  FCMPA_DB_INDEXER_NAME = "FCMPA_DB_INDEX"
  FCMPA_DB_FOLDER_NAME = "./DB/FCMPAM_DB_INDEX"
  FCMPA_DB_PARTITION_ARCHIVE_ID = 0
  FCMPA_DB_SIZE = 20
  FCMPA_DB_INDEX_LOCATION = 0
  FCMPA_DB_TRAVERSE_HASH = true

  # FCMPA_DB_[type]
  DB_PARTITION_AMOUNT = 9
  DB_PARTITION_OFFSET = 1
  DB_NAME = "FCMPA_DB"
  DB_PATH = "./DB/FCMPAM_DB"
  DB_HAS_CAPACITY = true
  DB_DYNAMICALLY_ALLOCATES = true
  DB_ENDLESS_ADD = true
  DB_MAX_CAPACITY = "data_arr_size"
  DB_PARTITION_ARCHIVE_ID = 0
  DB_SIZE = 20
  DB_PARTITION_ADDITION_AMOUNT = 5
  DB_TRAVERSE_HASH = true

  INITIAL_AUTOSAVE = true
  #TRAVERSE_HASH = true

  DATABASE_LIST_NAME = "_DATABASE_LIST_INDEX"
  LABEL_INTEGER = false
  LABEL_RANGES = false
  # db
  # fcmpa
  # man_db

  def initialize(db_max_capacity: DB_MAX_CAPACITY,
                 db_size: DB_SIZE,
                 db_endless_add: DB_ENDLESS_ADD,
                 db_has_capacity: DB_HAS_CAPACITY,
                 db_name: DB_NAME,
                 db_path: DB_PATH,
                 db_partition_addition_amount: DB_PARTITION_ADDITION_AMOUNT,
                 db_dynamically_allocates: DB_DYNAMICALLY_ALLOCATES,   
                 db_partition_amount_and_offset: DB_PARTITION_AMOUNT + DB_PARTITION_OFFSET,
                 db_partition_archive_id: DB_PARTITION_ARCHIVE_ID,
                 db_traverse_hash: DB_TRAVERSE_HASH,
                 fcmpa_db_size: FCMPA_DB_SIZE,
                 fcmpa_db_indexer_name: FCMPA_DB_INDEXER_NAME,
                 fcmpa_db_index_location: FCMPA_DB_INDEX_LOCATION, 
                 fcmpa_db_folder_name: FCMPA_DB_FOLDER_NAME,
                 fcmpa_db_partition_amount_and_offset: FCMPA_PARTITION_AMOUNT + FCMPA_OFFSET,
                 fcmpa_db_has_capacity: FCMPA_DB_HAS_CAPACITY, 
                 fcmpa_db_partition_addition_amount: FCMPA_DB_PARTITION_ADDITION_AMOUNT,
                 fcmpa_db_dynamically_allocates: FCMPA_DB_DYNAMICALLY_ALLOCATES,
                 fcmpa_db_endless_add: FCMPA_DB_ENDLESS_ADD,
                 fcmpa_db_max_capacity: FCMPA_DB_MAX_CAPACITY,
                 fcmpa_db_partition_archive_id: FCMPA_DB_PARTITION_ARCHIVE_ID,
                 fcmpa_db_traverse_hash: FCMPA_DB_TRAVERSE_HASH,
                 initial_autosave: INITIAL_AUTOSAVE,
                 active_database: nil,
                 active_table: nil,
                 traverse_hash: TRAVERSE_HASH,
                 label_integer: LABEL_INTEGER,
                 label_ranges: LABEL_RANGES)

    @fcmpa_db_partition_archive_id = fcmpa_db_partition_archive_id
    @fcmpa_db_endless_add = fcmpa_db_endless_add
    @fcmpa_db_partition_amount_and_offset = fcmpa_db_partition_amount_and_offset
    @fcmpa_db_max_capacity = fcmpa_db_max_capacity
    @fcmpa_db_index_location = fcmpa_db_index_location
    @fcmpa_db_size = fcmpa_db_size
    @fcmpa_db_indexer_name = fcmpa_db_indexer_name
    @fcmpa_db_folder_name = fcmpa_db_folder_name
    @fcmpa_db_partition_addition_amount = fcmpa_db_partition_addition_amount
    @fcmpa_db_has_capacity = fcmpa_db_has_capacity
    @fcmpa_db_dynamically_allocates = fcmpa_db_dynamically_allocates
    @fcmpa_db_partition_addition_amount = fcmpa_db_partition_addition_amount
    @fcmpa_db_traverse_hash = fcmpa_db_traverse_hash

    # The database which holds all the entries that the manager database manages
    @db_has_capacity = db_has_capacity
    @db_endless_add = db_endless_add
    @db_size = db_size
    @db_path = db_path
    @db_name = db_name
    @db_dynamically_allocates = db_dynamically_allocates
    @db_partition_amount_and_offset = db_partition_amount_and_offset
    @db_max_capacity = db_max_capacity
    @db_partition_addition_amount = db_partition_addition_amount
    @db_partition_archive_id = db_partition_archive_id
    @db_traverse_hash = db_traverse_hash
    @initial_autosave = initial_autosave
    @active_table = active_table
    @active_database = active_database

    @label_integer = label_integer
    @label_ranges = label_ranges

    @traverse_hash = traverse_hash
    #puts @db_partition_addition_amount
    @timestamp_str = Time.now.strftime("%Y-%m-%d-%H-%M-%S")
    #p "FCMPA: #{@label_integer}"
    @man_index = FileContextManagedPartitionedArray.new(fcmpa_db_partition_amount_and_offset: @fcmpa_db_partition_amount_and_offset,
                                                        fcmpa_db_size: @fcmpa_db_size,
                                                        fcmpa_db_indexer_name: @fcmpa_db_indexer_name+"_"+"indexer",
                                                        fcmpa_db_folder_name: @fcmpa_db_folder_name+"_"+"indexer",
                                                        fcmpa_db_dynamically_allocates: @fcmpa_db_dynamically_allocates,
                                                        fcmpa_db_endless_add: @fcmpa_endless_add,
                                                        fcmpa_db_partition_addition_amount: @man_db_partition_addition_amount,
                                                        fcmpa_db_has_capacity: @fcmpa_db_has_capacity,
                                                        fcmpa_db_index_location: @fcmpa_db_index_location,
                                                        fcmpa_db_max_capacity: @fcmpa_db_max_capacity,
                                                        fcmpa_db_partition_archive_id: @fcmpa_db_partition_archive_id,
                                                        db_partition_addition_amount: @db_partition_addition_amount,
                                                        db_size: @db_size,
                                                        db_endless_add: @db_endless_add,
                                                        db_has_capacity: @db_has_capacity,
                                                        db_name: @db_name, # difference: man_indexer instead of man_db_
                                                        db_path: @db_path, #
                                                        db_dynamically_allocates: @db_dynamically_allocates,
                                                        db_partition_amount_and_offset: @db_partition_amount_and_offset,
                                                        db_max_capacity: @db_max_capacity,
                                                        db_partition_archive_id: @db_partition_archive_id,
                                                        traverse_hash: @traverse_hash)

    # a man_db entry for every single database table, while man_index maintains the link between the manager database and the database tables
    @man_db = FileContextManagedPartitionedArray.new(fcmpa_db_partition_amount_and_offset: @fcmpa_db_partition_amount_and_offset,
                                                        fcmpa_db_size: @fcmpa_db_size,
                                                        fcmpa_db_indexer_name: @fcmpa_db_indexer_name+"_"+"database",
                                                        fcmpa_db_folder_name: @fcmpa_db_folder_name+"_"+"database",
                                                        fcmpa_db_dynamically_allocates: @fcmpa_db_dynamically_allocates,
                                                        fcmpa_db_endless_add: @fcmpa_endless_add,
                                                        fcmpa_db_partition_addition_amount: @man_db_partition_addition_amount,
                                                        fcmpa_db_has_capacity: @fcmpa_db_has_capacity,
                                                        fcmpa_db_index_location: @fcmpa_db_index_location,
                                                        fcmpa_db_max_capacity: @fcmpa_db_max_capacity,
                                                        fcmpa_db_partition_archive_id: @fcmpa_db_partition_archive_id,
                                                        db_partition_addition_amount: @db_partition_addition_amount,
                                                        db_size: @db_size, #
                                                        db_endless_add: @db_endless_add, #
                                                        db_has_capacity: @db_has_capacity, #
                                                        db_name: @db_name, # difference: man_indexer instead of man_db_
                                                        db_path: @db_path, #
                                                        db_dynamically_allocates: @db_dynamically_allocates, #
                                                        db_partition_amount_and_offset: @db_partition_amount_and_offset, #
                                                        db_max_capacity: @db_max_capacity, #
                                                        db_partition_archive_id: @db_partition_archive_id, #
                                                        traverse_hash: @traverse_hash,
                                                        label_integer: @label_integer,
                                                        label_ranges: @label_ranges)
    # Initialize the database which keeps track of all known databases that were created
    @man_db.start_database!(DATABASE_LIST_NAME, db_path: @db_path+"/MAN_DB_TABLE/#{DATABASE_LIST_NAME}/TABLE", only_path: true, only_name: true, db_name: "TABLE") # initialize the database list index
  end

  # gets the database object for the database_name (@man_index = database index; @man_db = database table)
  def database(database_name = @active_database)
    # check to see if this table exists in the database first
    return @man_index.db(database_name)
  end

  # gets the database table object for the database_table name, not needing a database x index pair
  def table(database_table = @active_table)
    return @man_db.db(database_table)
  end

  # set the active database table variable to avoid redundant typing
  def active_table(database_table)
    @active_table = database_table
  end

  # set the active database variable to avoid redundant typing
  def active_database(active_database)
    @active_database = active_database
  end

  def existing_database_tables?(database_name: @active_database)
    # check to see if this table exists in the database first
    @man_index.db(database_name).get(0)[database_name]["db_table_name"]
  end

  def [](database_name = @active_database, database_table = @active_table)
    database_table(database_table: database_table, database_name: database_name)
  end

  # gets the database table object for the database_table name, needing a database x index pair
  def database_table(database_name: @active_database, database_table: @active_table)
    # check to see if this table exists in the database first
    # @man_index.start_database!(database_name, db_path: @db_path+"/MAN_DB_INDEX/INDEX", only_path: true, only_name: true, db_name: "INDEX")
    # @man_db.start_database!(database_table, db_path: @db_path+"/MAN_DB_TABLE/#{database_name}/TABLE", only_path: true, only_name: true, db_name: "TABLE")

    if @man_index.db(database_name).get(0)[database_name]["db_table_name"].include? database_table
      return @man_db.db(database_table)
    end
    # if the table entry contains the table name in @man_index, then
  end

  # Lower level work that works with class variables within fcmpa_active_databases. In particular, the MPA within @man_db.fcmpa_active_databases[database_table]
  def table_set_file_context!(database_table: @active_table, database_name: @active_database, file_context_id: @db_partition_archive_id, save_prior: true, save_after: true)
    # @man_index.start_database!(database_name, db_path: @db_path+"/MAN_DB_INDEX/INDEX", only_path: true, only_name: true, db_name: "INDEX")
    # @man_db.start_database!(database_table, db_path: @db_path+"/MAN_DB_TABLE/#{database_name}/TABLE", only_path: true, only_name: true, db_name: "TABLE")
    @man_db.fcmpa_active_databases[database_table].save_everything_to_files! if save_prior
    @man_db.fcmpa_active_databases[database_table] = @man_db.fcmpa_active_databases[database_table].load_from_archive!(has_capacity: @db_has_capacity, dynamically_allocates: @db_dynamically_allocates, endless_add: @db_endless_add, partition_archive_id: file_context_id, db_size: @db_size, partition_amount_and_offset: @db_partition_amount_and_offset, db_path: @db_path+"/MAN_DB_TABLE/#{database_name}/TABLE", db_name: "TABLE", max_capacity: @db_max_capacity, partition_addition_amount: @db_partition_addition_amount)
    @man_db.fcmpa_active_databases[database_table].save_everything_to_files! if save_after
    @man_db.fcmpa_active_databases[database_table]
  end

  # sets the particular MPA running within the database as database_table to the next file context
  # lower level work that deals with class variables within fcmpa_active_databases
  def table_next_file_context!(database_table: @active_table, database_name: @active_database, save_prior: true, save_after: true)
    @man_db.fcmpa_active_databases[database_table].save_everything_to_files! if save_prior
    @man_db.fcmpa_active_databases[database_table] = @man_db.fcmpa_active_databases[database_table].archive_and_new_db!(has_capacity: @db_has_capacity, db_size: @db_size, partition_amount_and_offset: @db_partition_amount_and_offset, db_path: @db_path+"/MAN_DB_TABLE/#{database_name}/TABLE", db_name: "TABLE", max_capacity: @db_max_capacity, partition_addition_amount: @db_partition_addition_amount) 
    @man_db.fcmpa_active_databases[database_table].save_everything_to_files! if save_after
    @man_db.fcmpa_active_databases[database_table]
  end

  # update: left off worrying about the db_table_name entry having to contain an array of the table names so that the database knows which tables to look for and which ones belong to it
  # left off working with new_table, and, setting the table apart from the database and placing them into independent folders (the problem is file locations)
  def new_table!(database_table:, database_name:, initial_autosave: @initial_autosave)
    @man_index.start_database!(database_name, db_path: @db_path+"/MAN_DB_INDEX/INDEX", only_path: true, only_name: true, db_name: "INDEX")
    @man_db.start_database!(database_table, db_path: @db_path+"/MAN_DB_TABLE/#{database_name}/TABLE", only_path: true, only_name: true, db_name: "TABLE")

    old_db_table_name = @man_index.db(database_name).get(0).dig(database_name, "db_table_name")
    if old_db_table_name.nil?
      @man_index.db(database_name).set(0) do |hash|
        hash[database_name] = { "db_name" => database_name, "db_path" => @db_path+"/DB_#{database_name}", "db_table_name" => [database_table] }
      end
    else
      if !old_db_table_name.include?(database_table)
        @man_index.db(database_name).set(0) do |hash|
          hash[database_name] = { "db_name" => database_name, "db_path" => @db_path+"/DB_#{database_name}", "db_table_name" => old_db_table_name << database_table }
        end
      else
        #puts "table already exists, not updating"
      end
    end

    @man_index.db(database_name).save_everything_to_files! if initial_autosave
    @man_db.db(database_table).save_everything_to_files! if initial_autosave
    @man_db.db(database_table)
  end

  def delete_database_index_entry!(database_name)
    entry = @man_db.db(DATABASE_LIST_NAME).get(0)[DATABASE_LIST_NAME]
    @man_db.db(DATABASE_LIST_NAME).set(0) do |hash|
      hash[DATABASE_LIST_NAME] = entry.delete(database_name)
    end
    @man_db.db(DATABASE_LIST_NAME).save_everything_to_files!
    # @man_db.delete_database!(database_name)
  end

  # untested (1/12/2023 - 2:07PM)
  def delete_database!(database_name)
    @man_index.delete_database!(database_name)
    @man_index.fcmpa_active_databases.delete(database_name)
  end 

  # untested (1/12/2023 - 2:07PM)
  def delete_table!(database_table)
    @man_db.delete_database!(database_table)
    @man_db.fcmpa_active_databases.delete(database_table)
  end

  # the index is the database name, and man_db maintains the databases defined by the index
  def new_database!(database_name)
    @man_index.start_database!(database_name, db_path: @db_path+"/MAN_DB_INDEX/INDEX", only_path: true, only_name: false, db_name: "INDEX")
    # @man_db.start_database!(DATABASE_LIST_NAME, db_path: @db_path+"/MAN_DB_TABLE/#{DATABASE_LIST_NAME}/TABLE", only_path: true, only_name: true, db_name: "TABLE")
    index = []
    index = @man_db.db(DATABASE_LIST_NAME).get(0)[DATABASE_LIST_NAME]

    if index.nil?
      @man_db.db(DATABASE_LIST_NAME).set(0) do |hash|
        hash[DATABASE_LIST_NAME] = index
      end
    elsif !index.include?(database_name)
      @man_db.db(DATABASE_LIST_NAME).set(0) do |hash|
        hash[DATABASE_LIST_NAME] = index << database_name
      end
    end
    @man_db.db(DATABASE_LIST_NAME).save_everything_to_files!
    @man_db.fcmpa_active_databases[database_name] = @man_db.db(DATABASE_LIST_NAME)
  end

  alias db_table database_table
  alias active_db active_database
  alias new_db! new_database!
  alias new_tbl! new_table!

end

require_relative "file_methods"
require_relative "partitioned_array_database"

# which decomposes to FileContextManagedPartitionedArrayManager objects;
# which decomposes to FileContextManagedPartitionedArray objects;
# which decomposes to ManagedPartitionedArray objects, which inherits from the PartitionedArray class.
# VERSION v1.1.7-release: cleanup
# VERSION v1.1.6-release: label_integer and label_ranges for the ManagedPartitionedArray class, wherein you can define a set of integers or ranges separated by commas
# --and with the arguments set, set a hash like {id => object}
# VERSION v1.1.5-release: [] functions, which allows for selecting multiple databases
# VERSION v1.1.4-release: added traverse_hash constant and variable, added []; synchronized with file_context_managed_partitioned_array_manager.rb, partitioned_array_database.rb, and line_reader.rb--and managed_partitioned_array.rb
# VERSION v1.1.3-release: documentation in comments
# VERSION v1.1.2-release: fixed redundancy in the code
# VERSION v1.1.0-release: bug fixes, new features, and tested (partitioned_array/decomposition.rb)
# VERSION v1.0.3-release: bugs fixed and tested
# VERSION v1.0.2-release: rem_db -> remove_db, bugs fixed and tested
# VERSION v1.0.1-release: rem_db and add_db methods added
# VERSION v1.0.0-release
# VERSION v0.0.1 - Database creation by superfolder

# LineDB: Line Database - Create a database of PartitionedArrayDatabase objects;
class LineDB
  attr_accessor :parent_folder, :database_folder_name, :linelist, :database_file_name, :endless_add, :has_capacity, :db_size, :dynamically_allocates, :partition_amount, :traverse_hash

  include FileMethods
  PAD = PartitionedArrayDatabase

  ### Fallback Constants; a database folder and a db_list.txt file in the database folder must be present. ###
  ### db_list.txt must contain line separated sets of database names (see "lib/line_database_setup.rb") ###
  PARENT_FOLDER = "./db/CGMFS_db"
  DATABASE_FOLDER_NAME = "db"
  DATABASE_FILE_NAME = "./db/db_list.txt"

  ### Suggested Constants ###
  ENDLESS_ADD = true
  HAS_CAPACITY = true
  DATABASE_SIZE = 100
  DYNAMICALLY_ALLOCATES = true
  DATABASE_PARTITION_AMOUNT = 20
  TRAVERSE_HASH = true

  LABEL_INTEGER = false
  LABEL_RANGES = false

  ### /Suggested Constants ###

  def initialize(label_integer: LABEL_INTEGER, label_ranges: LABEL_RANGES, traverse_hash: TRAVERSE_HASH, database_partition_amount: DATABASE_PARTITION_AMOUNT, database_file_name: DATABASE_FILE_NAME, endless_add: ENDLESS_ADD, has_capacity: HAS_CAPACITY, db_size: DATABASE_SIZE, dynamically_allocates: DYNAMICALLY_ALLOCATES, parent_folder: PARENT_FOLDER, database_folder_name: DATABASE_FOLDER_NAME)
    @label_integer = label_integer
    @label_ranges = label_ranges
    @parent_folder = parent_folder
    @database_folder_name = database_folder_name
    @database_file_name = database_file_name
    @endless_add = endless_add
    @database_partiton_amount = database_partition_amount
    @has_capacity = has_capacity
    @db_size = db_size
    @dynamically_allocates = dynamically_allocates
    @traverse_hash = traverse_hash
    @linelist = load_pad(parent_folder: @parent_folder)    
  end

  # List of active databases
  def list_databases
    @linelist.keys
  end

  def [](*db_names)
    #@linelist[db_name]
    if db_names.size > 1
      return db_names.map { |db_name| @linelist[db_name] }
    else
      return @linelist[db_names[0]]
    end
  end

  def reload
    @linelist = load_pad(parent_folder: @parent_folder)
  end

  def db(db_name)
    @linelist[db_name]
  end

  def remove_db!(db_name)
    @linelist.delete(db_name)
    remove_line(db_name)
    remove_pad_single(db_name)
  end

  # TODO: implement rm_rf for dragonruby on windows and linux, and maybe android
  def delete_db!(db_name)
    FileUtils.rm_rf(db(db_name).database_folder_name)
    remove_db!(db_name)
  end

  def add_db!(db_name)
    write_line(db_name, @database_file_name) unless check_file_duplicates(db_name)
    load_pad_single(db_name)
  end

  #### Low level methods (but we don't enforce it lol, because they can still have their uses) ####
  # private

  def load_pad_single(db_name, parent_folder: @parent_folder || PARENT_FOLDER)
    db_linelist = read_file_lines(@database_file_name)
    if db_linelist.include?(db_name)
      @linelist[db_name] = PAD.new(label_integer: @label_integer, label_ranges: @label_ranges, traverse_hash: @traverse_hash, database_folder_name: db_name, endless_add: @endless_add, has_capacity: @has_capacity, dynamically_allocates: @dynamically_allocates, db_size: @db_size) if !parent_folder
      @linelist[db_name] = PAD.new(label_integer: @label_integer, label_ranges: @label_ranges, traverse_hash: @traverse_hash, database_folder_name: "#{parent_folder}/#{db_name}", endless_add: @endless_add, has_capacity: @has_capacity, dynamically_allocates: @dynamically_allocates, db_size: @db_size) if parent_folder
    end
  end

  def remove_pad_single(db_name)
    @linelist.delete(db_name)
  end

  # TODO: implement rm_rf for dragonruby on windows and linux, and maybe android
  def delete_pad_single(db_name)
    db_linelist = read_file_lines(@database_file_name)
    if db_linelist.include?(db_name)
      @linelist.delete(db_name)
      FileUtils.rm_rf(db(db_name).database_folder_name)
    end
  end

  def load_pad(parent_folder: @parent_folder || PARENT_FOLDER)
    db_linelist = read_file_lines(@database_file_name)
    db_list = {}
    db_linelist.each do |db_name|
      db_list[db_name] = PAD.new(label_integer: @label_integer, label_ranges: @label_ranges, traverse_hash: @traverse_hash, database_folder_name: db_name, endless_add: @endless_add, has_capacity: @has_capacity, dynamically_allocates: @dynamically_allocates, db_size: @db_size) if !parent_folder
      db_list[db_name] = PAD.new(label_integer: @label_integer, label_ranges: @label_ranges, traverse_hash: @traverse_hash, database_folder_name: "#{parent_folder}/#{db_name}", endless_add: @endless_add, has_capacity: @has_capacity, dynamically_allocates: @dynamically_allocates, db_size: @db_size) if parent_folder
    end
    db_list
  end
end

module FileMethods
  DB_LIST = "./db/db_list.txt"
  def read_lines(array)
    array.map { |line| line.chomp }
  end
  
  def read_multi_string(string)
    string.split("\n").map { |line| line.chomp }
  end
  
  def read_file_lines(file_name=DB_LIST)
    read_lines(File.readlines(file_name))
  end
  
  def write_line(line, filename=DB_LIST)
    File.open(filename, "a") do |f|
      f.puts line
    end
  end

  def remove_line(line, filename=DB_LIST)
    lines = read_file_lines
    lines.delete(line)
    File.open(filename, "w") do |f|
      lines.each do |line|
        f.puts line
      end
    end
  end
  
  
  
  def check_file_duplicates(check, filename=DB_LIST)
    lines = read_file_lines(filename)
    array_duplicates?(check, lines)
  end
  
  
  def array_duplicates?(check, array_of_strings)
    #puts array_of_strings.include?(check)
    array_of_strings.include?(check)
  end
  
  
  def write_lines(lines_array, filename=DB_LIST)
    lines_array.each do |line|
      File.open(filename, "a") do |f|
        f.puts line
      end
    end
  end
end
