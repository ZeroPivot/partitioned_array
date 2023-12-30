# Visuals; Show the basic data structure, by filling with entries, where each id is a part of that respective array partition
def allocate_ranges_sequentially(partitioned_array)
  range_arr = partitioned_array.range_arr
  range_arr.each_with_index do |range, range_index|
    range.to_a.each_with_index do |range_element, range_element_index|
      partitioned_array.set_partition_subelement(range_element_index, range_index) do |partition_subelement|
        partition_subelement["id"] = range_index
      end
    end
  end
  partitioned_array.data_arr
end