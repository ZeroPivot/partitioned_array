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
# frozen_string_literal: true

# Ranged binary search, for use in CGMFS
# array_id = relative_id - db_size * (PARTITION_AMOUNT + 1)

# When checking and adding, see if the index searched for in question

# when starting out with the database project itself, check to see if the requested id is a member of something like rel_arr

# 1) allocate range_arr and get the DB running
# 2) allocate rel_arr based on range_arr
# 3) allocate the actual array (@data_arr)
# VERSION v1.1.3 (2022/03/31)
# VERSION v1.1.2 (2022/03/31 - 4:05:am) - refined and created reference to the algorithm
# VERSION v1.1.1 (2022/03/20 - 8:38 PM)
# * performed a minor regression and corrected a couple bugs
# VERSION: v1.1.0 (2022/03/30 - 3:46PM)
# Implemented all the necessary features for the PA to work, except for an add_from_lefr or add_from_right, which will
# attempt to fill in the gaps in the database.
# TODO: implement pure json parsing
# * Notes: Have to manually convert all the string data to their proper data structure
#  * HURDLE: converting strings to their proper data structures is non-trivial; could check stackoverflow for a solution
# VERSION v1.0 (2022/03/30) - finished functions necessary for the partitioned array to be useful
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
PURE_RUBY = true
unless PURE_RUBY
  require 'json'
else
  require_relative "json_eval"
end
require 'fileutils'

class PartitionedArray
  attr_accessor :range_arr, :rel_arr, :db_size, :data_arr, :partition_amount_and_offset, :db_path, :db_name

  # DB_SIZE > PARTITION_AMOUNT
  VERSION = "v1.1.2"
  PARTITION_AMOUNT = 5 # The initial, + 1
  OFFSET = 1 # This came with the math
  DB_SIZE = 3 # Caveat: The DB_SIZE is the total # of partitions, but you subtract it by one since the first partition is 0, in code.
  DEFAULT_PATH = './CGMFS' # default fallback/write to current path
  DEBUGGING = false
  DB_NAME = 'partitioned_array_slice'

  def initialize(db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: DEFAULT_PATH, db_name: DB_NAME)
    @db_size = db_size
    @partition_amount_and_offset = partition_amount_and_offset
    @allocated = false
    @db_path = db_path
    @data_arr = [] # the data array which contains the data, has to be partitioned accordingly
    @range_arr = [] # the range array which maintains the partition locations
    @rel_arr = [] # a basic array from 0..n used in binary search
    @db_name = db_name
    debug "test"
  end

  def range_db_get(range_arr, db_num)
    range_arr[db_num]
  end

  def debug(string)
    p string if DEBUGGING
  end

  def <<(data); end

  def push(data); end

  def shift(data); end

  # set the partition's array element to what is specified
  def set_partition_subelement(id, partition_id, &block)
    set_successfully = false
    # set the partition's array element to what is specified
    partition = get_partition(partition_id)
    if id <= (@data_arr.size - 1) && partition
      if block_given? && partition[id].instance_of?(Hash)
        block.call(partition[id])
        set_successfully = true
      else
        debug "error"
        set_successfully = false
      end
    end
    set_successfully
  end

  def get_partition(partition_id)
    # get the partition id data
    debug "Partion ID: #{partition_id}"
    if partition_id <= @db_size - 1
      @data_arr[@range_arr[partition_id]]
    else
      debug "SliceID #{partition_id} is out of bounds."
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

  # create an initial database (instance variable)
  # later on, make this so it will load a database if its there, and if there's no data, create a standard database then save it
  # Set to work with the default constants
  def allocate(db_size: @db_size, partition_amount_and_offset: @partition_amount_and_offset, override: false)
    if !@allocated || override
      @allocated = false
      @rel_arr = (0..(db_size * partition_amount_and_offset)).to_a
      debug "@rel_arr: #{@rel_arr}"
      partition = 0

      db_size.times do
        if @range_arr.empty?
          partition += partition_amount_and_offset
          @range_arr << (0..partition)
          next
        end
        partition += partition_amount_and_offset
        @range_arr << ((partition - partition_amount_and_offset + 1)..partition)
        debug "@range_arr: #{@range_arr}"
      end

      x = 0 # offset test, for debug purposes
      @data_arr = (0..(db_size * (partition_amount_and_offset - x))).to_a.map { {} } # for an array that fills to less than the max of @rel_arr
      # @data_arr = (0..(db_size * (partition_amount_and_offset - x))).to_a.map { nil }
      @allocated = true
    else
      debug 'Initial database has been already allocated.'
    end
    debug "@data_arr element count: #{@data_arr.flatten.count - 1}"
    debug "@data_arr: #{@data_arr}"

    @allocated = true
  end

  # Returns a hash based on the array element if you are searching for.
  def get(id, hash: false)
    return nil unless @allocated # if the database has not been allocated, return nil
    return @data_arr if id.nil?
    return @data_arr.first if id.zero?
    return @data_arr.last if id == @data_arr.count - 1

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
        data = { "data_partition" => @data_arr[@range_arr[db_index]], "db_index" => db_index, "array_id" => array_id, "data" => @data_arr[@range_arr[db_index].to_a[array_id]] }
      else
        data = @data_arr[@range_arr[db_index].to_a[array_id]]
      end
    end
    data
  end

  def add_partition
    # add a partition to the @range_arr, add partition_amount_and_offset to @rel_arr, @db_size increases by one
    last_range_num = @range_arr.last.to_a.last
    @range_arr << ((last_range_num + 1)..(last_range_num + @partition_amount_and_offset))
    (@rel_arr.last).upto(@rel_arr.last + @partition_amount_and_offset) do |i|
      @rel_arr << i
    end

    @db_size += 1
    @partition_amount_and_offset.times { @data_arr << {} } # initialize new partition within array to nils
    # @partition_amount_and_offset.times { @data_arr << nil} # initialize new partition within array to nils
    debug "Partition added successfully; data allocated"
    debug "@data_arr: #{@data_arr}"
    # @partition_amount_and_offset.times { nil }
  end

  # When loading a JSON database file (*_db.json), the related @ arr variables need to be set to what is within the JSON file database.
  # This means the need to parse a file, and @allocated is set to true in the end.

  def string2range(range_string)
    split_range = range_string.split("..")
    split_range[0].to_i..split_range[1].to_i
  end

  # loads the files within the directory CGMFS/partitioned_array_slice
  # needed things
  # range_ar} => it is the array of ranges that the database is divided into
  # data_ar} => it is output to json
  # rel_ar} => it is output to json
  # part_} => it is taken from the range_ar} subdivisions; perform a map and load it into the database, one by one
  def load_from_json!(db_folder: @db_folder)
    path = "#{@db_path}/#{@db_name}"
    @data_arr = File.open("#{path}/data_arr.json", 'r') { |f| JSON.parse(f.read) }
    @partition_amount_and_offset = File.open("#{path}/partition_amount_and_offset.json", 'r') { |f| JSON.parse(f.read) }
    @range_arr = File.open("#{path}/range_arr.json", 'r') { |f| JSON.parse(f.read) }
    @range_arr.map! { |range_element| string2range(range_element) }
    @rel_arr = File.open("#{path}/rel_arr.json", 'r') { |f| JSON.parse(f.read) }
  end

  def pure_load_from_json!(db_folder: @db_folder); end

  def array_all_nils?(array)
    array.all?(&:nil?)
  end

  # Complete
  def pure_load_partition_from_file!(partition_id)
    path = "#{@db_path}/#{@db_name}"
    data_arr = File.open("#{path}/data_arr.json", 'r') { |f| ::JSONeval.data_arr2ruby(f.read) }
    @partition_amount_and_offset = File.open("#{path}/partition_amount_and_offset.json", 'r') { |f| ::JSONeval.partition_amount_and_offset2ruby(f.read) }
    @range_arr = File.open("#{path}/range_arr.json", 'r') { |f| ::JSONeval.range_arr2ruby(f.read) }
    p @range_arr
    @range_arr.map! { |range_element| string2range(range_element) }
    @rel_arr = File.open("#{path}/rel_arr.json", 'r') { |f| ::JSONeval.json2ruby(f.read) }
    puts "@range_arr: #{@range_arr}"
    sliced_range_arr = @range_arr[partition_id].to_a.map do |range_element|
      p range_element
      range_element
    end
    sliced_range_arr = sliced_range_arr[0]..sliced_range_arr[-1]

    partition_data = File.open("#{path}/#{@db_name}_part_#{partition_id}", 'r') { |f| ::JSONeval.json2ruby(f.read) }
    puts "sliced_range_arr: #{sliced_range_arr}"
    sliced_range_arr.to_a.each do |range_element|
      puts "debug: #{range_element}"
      @data_arr[range_element] = data_arr[range_element]
    end
    @data_arr[@range_arr[partition_id]]
  end

  # Using Ruby's JSON library
  def load_partition_from_file!(partition_id)
    path = "#{@db_path}/#{@db_name}"
    @data_arr = File.open("#{path}/data_arr.json", 'r') { |f| JSON.parse(f.read) }
    @partition_amount_and_offset = File.open("#{path}/partition_amount_and_offset.json", 'r') { |f| JSON.parse(f.read) }
    @range_arr = File.open("#{path}/range_arr.json", 'r') { |f| JSON.parse(f.read) }
    @range_arr.map! { |range_element| string2range(range_element) }
    @rel_arr = File.open("#{path}/rel_arr.json", 'r') { |f| JSON.parse(f.read) }
    sliced_range_arr = @range_arr[partition_id].to_a.map { |range_element| range_element }
    partition_data = File.open("#{path}/#{@db_name}_part_#{partition_id}", 'r') { |f| JSON.parse(f.read) }
    ((sliced_range_arr[0].to_i)..(sliced_range_arr[-1].to_i)).to_a.each do |range_element|
      @data_arr[range_element] = partition_data[range_element]
    end
    @data_arr[@range_arr[partition_id]]
  end

  def save_partition_to_file!(partition_id, db_folder: @db_folder)
    partition_data = get_partition(partition_id)
    path = "#{@db_path}/#{@db_name}"
    File.open("#{path}/#{db_folder}/#{@db_name}_part_#{partition_id}", 'w') { |f| f.write(partition_data.to_json) }
  end

  def pure_save_partition_to_file!(partition_id, db_folder: @db_folder)
    partition_data = get_partition(partition_id)
    path = "#{@db_path}/#{@db_name}"
    File.open("#{path}/#{db_folder}/#{@db_name}_part_#{partition_id}", 'w') { |f| f.write(::JSONeval.ruby2json(partition_data)) }
  end

  def dump_to_json!(db_folder: @db_folder)
    unless Dir.exist?(@db_path)
      Dir.mkdir(@db_path)
    end
    path = "#{@db_path}/#{@db_name}"

    unless Dir.exist?(path)
      Dir.mkdir(path)
    end

    File.open("#{path}/#{db_folder}/partition_amount_and_offset.json", 'w') { |f| f.write(@partition_amount_and_offset.to_json) }
    File.open("#{path}/#{db_folder}/range_arr.json", 'w') { |f| f.write(@range_arr.to_json) }
    File.open("#{path}/#{db_folder}/data_arr.json", 'w') { |f| f.write(@data_arr.to_json) }
    File.open("#{path}/#{db_folder}/rel_arr.json", 'w') { |f| f.write(@rel_arr.to_json) }
    debug path
    @range_arr.each_with_index do |_, index|
      FileUtils.touch("#{path}/#{@db_folder}/#{@db_name}_part_#{index}")
      File.open("#{path}/#{@db_name}_part_#{index}", 'w') do |f|
        partition = get_partition(index)
        f.write(partition.to_json)
        debug partition.to_json
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