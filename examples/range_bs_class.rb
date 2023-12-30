# rubocop:disable Metrics/AbcSize
# rubocop:disable Style/GuardClause
# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
# rubocop:disable Style/IfUnlessModifier
# rubocop:disable Layout/LineLength

# Ranged binary search, for use in CGMFS
# array_id = relative_id - db_size * (PARTITION_AMOUNT + 1)

# When checking and adding, see if the index searched for in question

# when starting out with the database project itself, check to see if the requested id is a member of something like rel_arr

# 1) allocate range_arr and get the DB running
# 2) allocate rel_arr based on range_arr

# An array system that is partitioned at a lower level, but functions as an almost-normal array at the high level
class PartitionedArray
  attr_reader :range_arr, :rel_arr, :db_size

  PARTITION_AMOUNT = 4
  OFFSET = 1
  DB_SIZE = 3
  DEFAULT_PATH = './test_db.json'
  DEBUGGING = true

  def initialize(db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: DEFAULT_PATH)
    # Allocate initially on PartitionedArray.new, but only if you want to
    @db_size = db_size
    @partition_amount_and_offset = partition_amount_and_offset
    @allocated = false
    @db_path = db_path
    @data_arr = [] # the data array which contains the data, has to be partitioned accordingly
    @range_arr = []
    @rel_arr = []
    @max_subscript = 0 # Last element in @data_arr
  end

  def debug(string)
    p string if DEBUGGING
  end

  def <<(data); end

  def last_status; end

  def set(id); end

  def get(id); end

  def build_range_arr; end

  def allocate(db_size: @db_size, partition_amount_and_offset: @partition_amount_and_offset, db_path: @db_path)
    # Critical error, a path is always needed
    if db_path.nil? && !load_database 
      raise '@db_path (Database File Path) has not been set.'
    end

    if !@allocated
      @rel_arr = (0..(db_size * partition_amount_and_offset)).to_a
      debug("@rel_arr: #{@rel_arr}")
      partition = 0
      @db_size.times do
        if @range_arr.empty?
          partition += partition_amount_and_offset
          @range_arr << [0..(partition - 1)]
          next
        end

        partition += partition_amount_and_offset
        @range_arr << [(partition - partition_amount_and_offset)..partition]
      end
      debug("@range_arr: #{@range_arr}")
      ## TODO: At this point, this is where the @data_array file will be loaded, but for test-
      ## ing purposes, fill the array with random data such that the max number matches the already
      ## generated partition reference arrays (2:47PM 17/7/2021)
      ## Note: need to make it so that @data_arr is partitioned like @range_arr, but it's not at the moment
      ##
      # @data_arr = (0..(db_size * partition_amount_and_offset)).to_a.map {rand(0..1_000_000)} # for an array that fills to the limit
      #
      x = 2
      @data_arr = (0..(db_size * (partition_amount_and_offset - x))).to_a.map {rand(0..1_000_000)} # for an array that fills to less than the max of @rel_arr
      @max_subscript = @data_arr.size # get the max of the array before it is partitioned
      #
      @data_arr = @data_arr.each_slice(partition_amount_and_offset - 1).to_a
      
      debug("@max_subscript: #{@max_subscript}")
      debug("@data_arr: #{@data_arr}")
      debug("@data_arr count: #{@data_arr.flatten.count}")
      ##
      ##
      # @range_arr = Array.new(db_size)
      # @rel_arr = Array.new(db_size) # allocate this based on the range_arr
      @allocated = true
    else
      debug('Already allocated; set reallocate argument to false to skip reallocation')
    end
  end

  def add_partition
    # add a partition to the @range_arr, reallocate @rel_arr, @db_size increases by one
  end

  def reallocate
  end

  def to_r; end

  def load!(db_path: @db_path); end

  def save!(db_path: @db_path); end

  def find(id); end

  def check(id); end

  def add(id); end

  def delete(id); end

  def delete_all; end

  def clear; end

  def size; end

  def empty?; end

  def each; end

  def to_a; end

  def to_s; end

  def rebuild
    # rebuild the rel_arr based on the range_arr
  end
end

y = PartitionedArray.new
y.allocate

# # When checking and adding, see if the index searched for in question
# PARTITION_AMOUNT = 10
# OFFSET = 1
#
#
# rel_arr = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33]
#
# range_arr = [0..10, 11..22, 22..33] # in the field, the range array will have to be split according to the array, and the max id needs to match the last range
#
# def range_db_get(range_arr, db_num)
#   range_arr[db_num]
# end
#
# db_index = nil
# relative_id = nil
#
# range_arr.each_with_index do |range, index|
#   relative_id = range.bsearch { |element| rel_arr[element] >= 33 }
#
#   if relative_id
#     db_index = index
#     # we check to see if the relative id in the rel_arr matches the range
#     if range_db_get(range_arr, db_index).member? rel_arr[relative_id]
#       break # If so, then break out of this iteration
#     end
#   else
#     # If relative_id is nil, we don't have an entry at that location (aside from mismatching numbers)
#     db_index = nil
#     relative_id = nil
#   end
# end
#
# if relative_id
#   array_id = relative_id - db_index * (PARTITION_AMOUNT + OFFSET)
# end
#
# relative id is nil if no element was found
# p "DB number id (db_index): #{db_index}" if relative_id
# p "The array database resides in (array_id): #{array_id}" if relative_id
# p "The array resulting value is (relative_id): #{relative_id}" if relative_id
#
# unless relative_id
#   puts 'The value could not be found'
# end

# rubocop:enable Layout/LineLength
# rubocop:enable Style/IfUnlessModifier
# rubocop:enable Metrics/MethodLength
# rubocop:enable Style/GuardClause
# rubocop:enable Metrics/AbcSize
