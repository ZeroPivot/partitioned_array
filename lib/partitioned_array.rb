# rubocop:disable Style/MutableConstant
# rubocop:disable Style/GuardClause
# rubocop:disable Style/ConditionalAssignment
# rubocop:disable Style/StringLiterals
# rubocop:disable Metrics/ClassLength
# rubocop:disable Style/UnlessElse
# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
# rubocop:disable Style/IfUnlessModifier
# rubocop:disable Layout/LineLength
# VERSION v2.0.1-release - remove :last and :first in favor of [:all].last and [:all].first; update in DRAGONRUBY ACCORDINGLY (2/7/2023 11:14AM)
# VERSION v2.0.0-release - add :all :last :first keywords to [] method, unrefined and untested
# VERSION v1.2.4-release - cleanup puts in add_partition 
# VERSION v1.2.3-release - @label_integer and @label_ranges, sync with line_db, etc
# VERSION v1.2.2-release - @label_integer and @label_ranges
# VERSION v1.3.1-release
# VERSION v1.3.0-release - 1/13/2023 - 1:39AM
# VERSION v1.2.9-release - [](id ...) - accepts ranges, and integers as an argument splat
### Functionality: label the ranges and/or the integer values in the [] arguments with a hash argument
### --with keys pointing to the get values (for integers and/or ranges) 
### label_ranges: true
### label_integer: true
# VERSION v1.2.8 - [](id, hash: false) - 1/13/2023
# VERSION: v1.2.7 - implemented [](id) - uses get(id, hash: false) - 1/13/2023
# VERSION: v1.2.6 - cleanup; plan on being able to save @data_arr to file directly (not by partitions) - 10/19/2022 2:03PM
# VERSION v1.2.5a - endless add implementation in ManagedPartitionedArray#endless_add
# Allows the database to continuously add and allocate, as if it were a plain PartitionedArray
# VERSION v1.2.4 - now its not "data_arr_size" if you set the variable correctly
# Note: The struct may require more work, but this struct in particular is not necessary in the managed partitioned array
# -- too many allocations are done when 'at capacity', but its because of the nature of the beast
# VERSION v1.2.4 - fixed a bug with allocations, also modified in ManagedPartitionedArray
# VERSION v1.2.3 - fully functional in tandem with ManagedPartitionedArray; added a few more tests (9/13/2022 - 5:48am)
# VERSION v1.2.2 - after adding partitions, every partition is saved to reflect the new changes on disk
# VERSION v1.2.1 - fixed PartitionedArray#get(id, &block) bugs
#                 - file cleanup
# VERSION v1.2.0 - Cleanup according to rubocop and solargraph linter; clarification in places added (8/11/2022 - 6:01am)
# VERSION v1.1.1 - Documenting code and scanning for bugs and any version wrap-ups
#     -   v1.1.2 - PartitionedArray#add(return_added_element_id: true, &block): return element id of the location of the addition 
# VERSION v1.1.0a (8/11/2022 - 5:11am)
# -- PartitionedArray#add_partition now works correctly.
#    Various bug fixes that lead to array variable inconsistencies

# VERSION v1.0.5a (7/30/2022)
# -- So far the partitioned array works with allocation of partitions, saving to files, and loading from files.
# PROBLEM/BUG: PartitionedArray#add_partition does not allocate and manage the variables correctly
# IT: upon the need to add a new partition, it adds but the entry is added to the end of the @data_arr
# partition, extending its length by one which is not what we want.
# VERSION v1.0.5 (7/30/2022)
# More bug fixes, notable in saving and loading data from files.
# Example:

# partition0: [{"log"=>"Hello World"}, {"log"=>"Hello World"}, {"log"=>"Hello World"}, {"log"=>"Hello World"}, {"log"=>"Hello World"}]
# partition1: [{"log"=>"Hello World"}, {"log"=>"Hello World"}, {"log"=>"Hello World"}, {"log"=>"Hello World"}, {"log"=>"Hello World", :log=>"Hello World"}]
# partition2: [{}, {}, {}, {}, {}]S
# partition3: [{}, {}, {}, {}, {}]
# partition4: [{}, {}, {}, {}, {}]

# partition0 is the length that the partitions should be in this case, p_1 had an entry appended to itself somehow, and 
# PartitionedArray won't add any more entries to it, once it reaches its max and has an additional element added.

# VERSION v1.0.4 (7/30/2022 9:37PM)
# Various bug fixes and improvements.
# PartitionedArray#load_from_files! now works without throwing nil entries.

# VERSION v1.0.3 (7/30/2022 2:42PM)
# Added ManagedPartitionedArray for CGMFS, which inherits from PartitionedArray and adds the following functionality:
# - last_entry
# => last_entry is a variable that keeps track of the last entry that was added to the database, in terms of a @data_arr
# since PartitionedArray is dynamically allocated, it is not possible to know the last entry that was added to the database

# VERSION v1.0.2a
# All necessary instance methods have been implemented, ready for real world testing...

# Ranged binary search, for use in CGMFS
# array_id = relative_id - db_size * (PARTITION_AMOUNT + 1)

# When checking and adding, see if the index searched for in question

# when starting out with the database project itself, check to see if the requested id is a member of something like rel_arr

# 1) allocate range_arr and get the DB running
# 2) allocate rel_arr based on range_arr
# 3) allocate the actual array (@data_arr)
# VERSION: v1.0.2
# VERSION: v1.0.1a - set_partition_subelement
# VERSION: v1.0.0 - all essential functions implemented
# 5/9/20 - 5:54PM
# TODO:
# def save_partition_element_to_file!(partition_id, element_id, db_folder: @db_folder)

# VERSION: v1.0.0 (2022/03/30 - 3:46PM)
# Implemented all the necessary features for the PA to work, except for an add_from_lefr or add_from_right, which will
# attempt to fill in the gaps in the database.
# TODO: implement pure json parsing

# * Notes: Have to manually convert all the string data to their proper data structure
#  * HURDLE: converting strings to their proper data structures is non-trivial; could check stackoverflow for a solution
# VERSION v2.0 (4/22/2022) - added PartitionedArray#add(&block) function, to make additions to the array fast (fundamental method)
# VERSION v0.6 (2022/03/30) - finished functions necessary for the partitioned array to be useful
# VERSION: v0.5 (2022/03/14)
# Implemented
# PartitionedArray#get_part(partition_id) # => returns the partition specified by partition_id or nil if it doesn't exist
# PartitionedArray#add_part(void) # => adds a partition to the array, bookkeeping is done in the process
# VERSION: v0.4 (11:55PM)
# Fixed bugs, fixed array_id; allocate and get are fully implemented and working correctly for sure
# VERSION: v0.3 (3:46PM)
# allocate and get(id) are seemingly fully implemented and working correctly
# * start work on "allocate_file!"
# VERSION: v0.2 (02.28/2022 3:10PM)
# Currently working on get(id).
# VERSION: v0.1 (12/9/2021 12:31AM)
# Implementing allocate
# SYNOPSIS: An array system that is partitioned at a lower level, but functions as an almost-normal array at the high level
# DESCRIPTION:
# This is a system that is designed to be used as a database, but also as a normal array.
# NOTES:
# When loading a JSON database file (*_db.json), the related @ arr variables need to be set to what is within the JSON file database.
# This means the need to parse a file, and @allocated is set to true in the end.
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

  # 2/7/2023 10:39AM
  #examine closely later (also: this was never imnplemented in DragonRuby's PartitionedArray classes)
  def [](*ids, hash: false, label_ranges: @label_ranges, label_integer: @label_integer)
    #puts "ids: #{ids[0]}"
    @elements = []
    if (ids[0] == "all" || ids[0] == :all)
      # setup for "all" or :all as an only argument in the array subscript for now to get the entire @data_arr
      0.upto(@db_size - 1) do |element_id|
        # puts "element_id: #{element_id}"
        @elements << @data_arr[element_id]
      end
      return @elements
    end
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

# rubocop:enable Layout/LineLength
# rubocop:enable Style/IfUnlessModifier
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/PerceivedComplexity
# rubocop:enable Style/UnlessElse
# rubocop:enable Metrics/ClassLength
# rubocop:enable Style/StringLiterals
# rubocop:enable Style/ConditionalAssignment
# rubocop:enable Style/GuardClause
# rubocop:enable Style/MutableConstant
