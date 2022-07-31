# rubocop:disable Style/FrozenStringLiteralComment
# rubocop:disable Style/IfUnlessModifier
# rubocop:disable Layout/LineLength

# Ranged binary search, for use in CGMFS
# array_id = relative_id - db_num * (PARTITION_AMOUNT + 1)

# When checking and adding, see if the index searched for in question
PARTITION_AMOUNT = 10
OFFSET = 1

# when starting out with the database project itself, check to see if the requested id is a member of something like rel_arr
rel_arr = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32]

range_arr = [0..10, 11..21, 22..32] # in the field, the range array will have to be split according to the array, and the max id needs to match the last range
puts range_arr
def range_db_get(range_arr, db_num)
  range_arr[db_num]
end

db_index = nil
relative_id = nil
puts range_arr
range_arr.each_with_index do |range, index|
  relative_id = range.bsearch { |element| rel_arr[element] >= 33 } 
  
  if relative_id
    db_index = index
    # we check to see if the relative id in the rel_arr matches the range
    if range_db_get(range_arr, db_index).member? rel_arr[relative_id]
      break # If so, then break out of this iteration
    end
  else
    # If relative_id is nil, we don't have an entry at that location (aside from mismatching numbers)
    db_index = nil
    relative_id = nil
  end
end

if relative_id
  array_id = relative_id - db_index * (PARTITION_AMOUNT + OFFSET)
end

# relative id is nil if no element was found
p "DB number id (db_index): #{db_index}" if relative_id
p "The array database resides in (array_id): #{array_id}" if relative_id
p "The array resulting value is (relative_id): #{relative_id}" if relative_id

unless relative_id
  puts 'The value could not be found'
end

# rubocop:enable Layout/LineLength
# rubocop:enable Style/IfUnlessModifier
# rubocop:enable Style/FrozenStringLiteralComment
